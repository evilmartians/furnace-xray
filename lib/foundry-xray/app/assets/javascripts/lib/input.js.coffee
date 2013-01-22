#
# Input mapper for a single function taken from JSON input
#
class @Input
  constructor: (@source) ->
    @function = new FunctionNode(@source.name, @source.events)
    @rebuild()

  rebuild: (step) ->
    step ||= @function.events.length-1
    stop   = [step, @function.events.length-1].min()

    # Clear storages
    @types  = {}
    @edges  = []

    @blocks          = {}
    @blocksMap       = []
    @instructions    = {}
    @instructionsMap = []

    # Function is our root node
    @nodes = [
      {
        edges: [],
        label: => @function.title()
      }
    ]

    # Evaluating required steps
    i=0; while (i += 1) <= stop
      event = @function.events[i]

      if event.event == 'type'
        @types[event.id] = new TypeNode(event.kind, event.name, event.parameters)
      else
        @[event.event]?(event)
        console.log "UNKNOWN EVENT: #{event.event}" unless @[event.event]?

    # Now that our graph is ready we need to evaluate labels
    @nodes.each (n) -> n.label = n.label()

  setReturnType: (event) ->
    @function.setReturnType @types[event.return_type]

  setArguments: (event) ->
    @function.setArguments(event.arguments.map (x) => new ArgumentNode(x.name, @types[x.type]))

  addBasicBlock: (event) ->
    id = @blocksMap.findIndex(event.name)

    if id < 0
      @blocksMap.add event.name
      id = @blocksMap.length-1

    @blocks[id] = new BlockNode(event.name)
    @nodes.add {
      edges: []
      label: => @blocks[id].title()
      block: id
    }

  removeBasicBlock: (event) ->
    id = @blocksMap.findIndex(event.name)
    @blocksMap.splice(id, 1)

    unless id < 0
      delete @blocks[id]
      @nodes.splice @nodes.findIndex((x) -> x.block == id), 1

  renameBasicBlock: (event) ->
    id = @blocksMap.findIndex(event.name)

    @blocksMap[id] = event.new_name
    @blocks[id].setName(event.new_name)

  updateInstruction: (event) ->
    id = @instructionsMap.findIndex(event.name)

    if id < 0
      @instructionsMap.add event.name
      id = @instructionsMap.length-1
      @instructions[id] = new InstructionNode

    operands = event.operands.map (x) =>
      new OperandNode x.kind, @types[x.type], x.name, x.value

    @instructions[id].update event.opcode, event.name, event.parameters, operands, event.type