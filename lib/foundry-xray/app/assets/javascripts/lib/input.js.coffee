#
# Internal representation of input JSON
#
class @Input
  constructor: (@source) ->
    @function = new FunctionNode(@source.name, @source.events)

    @events = []
    @function.events.filter (x, i) =>
      unless ['type', 'transformStart'].any(x.event)
        @events.add i

  rebuild: (step) ->
    step  = @events.length-1 unless step?
    @stop = [step, @events.length-1].min()

    # Clear storages
    @types           = Object.extended()
    @blocks          = Object.extended()
    @instructions    = Object.extended()
    @visibleEvents   = Object.extended()
    @blocksMap       = new Map 'blocks'
    @instructionsMap = new Map 'instructions'

    # Evaluating required steps
    i=-1; while (i += 1) <= @events[@stop]
      event = @function.events[i]

      if event.event == 'type'
        @types[event.id] = new TypeNode(event.kind, event.name, event.parameters)
      else
        @[event.event]?(event)
        console.log "UNKNOWN EVENT: #{event.event}" unless @[event.event]?

  type: (id) ->
    return undefined unless id?

    if type = @types[id]
      return type
    else
      throw "Type #{id} not found in #{@types.keys().join(',')}"

  setReturnType: (event) ->
    @function.setReturnType @type(event.return_type)

  setArguments: (event) ->
    @function.setArguments(event.arguments.map (x) =>
      new ArgumentNode(x.name, @type(x.type)))

  addBasicBlock: (event) ->
    @blocksMap.add event.name, (id) =>
      @blocks[id] = new BlockNode(event.name)

  removeBasicBlock: (event) ->
    @blocksMap.remove event.name, (id) =>
      delete @blocks[id]

  renameBasicBlock: (event) ->
    @blocksMap.rename event.name, event.new_name, (id) =>
      @blocks[id].setName(event.new_name)

  updateInstruction: (event) ->
    id = @instructionsMap.add event.name, (id) =>
      @instructions[id] = new InstructionNode

    operands = event.operands.map (x) =>
      new OperandNode x.kind, @type(x.type), x.name, x.value

    @instructions[id].update event.opcode, event.name, event.parameters, operands, @type(event.type)

  addInstruction: (event) ->
    @instructionsMap.locate event.name, (i) =>
      @blocksMap.locate event.basic_block, (b) =>
        @instructions[i].link @blocks[b], event.index

  removeInstruction: (event) ->
    @instructionsMap.locate event.name, (i) =>
      @instructions[i].unlink()

  transformStart: (event) ->