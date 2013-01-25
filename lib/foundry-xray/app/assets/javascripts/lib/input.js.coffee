#
# Internal representation of input JSON
#
class @Input
  @normalize: (data) ->
    data.map (x) -> new Input(x)

  constructor: (@source) ->
    @source.events.each (x) -> x.event = x.event.camelize(false)

    # Scan for effective events
    @events = []
    reducer = []
    transforms = Object.extended()

    @source.events.each (x, i) =>
      switch x.event 
        when 'addInstruction'
          reducer.add x.name
          @events.add i
        when 'removeInstruction'
          reducer.exclude x.name
          @events.add i
        when 'updateInstruction'
          @events.add i if reducer.any(x.name)
        when 'type', 'transformStart'
        else
          @events.add i

      if x.event == 'transformStart'
        id = @events.length-1
        transforms[id] = {id: id, label: x.name}

    @transforms = transforms.values()
    @transforms = @transforms.filter (x, i) => 
      x.length = (@transforms[i+1]?.id || @events.length) - x.id
      x.id < @events.length-1
          

  rebuild: (step) ->
    @function = new FunctionNode(@source.name, @source.present)

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
      event = @source.events[i]

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

    if Object.isArray(event.operands)
      operands = event.operands.map (x) =>
        new OperandNode x.kind, @type(x.type), x.name, x.value
    else
      operands = []
      Object.each event.operands, (key, x) =>
        operands.push [key, new OperandNode(x.kind, @type(x.type), x.name, x.value)]

    @instructions[id].update event.opcode, event.name, event.parameters, operands, @type(event.type)

  addInstruction: (event) ->
    @instructionsMap.locate event.name, (i) =>
      @blocksMap.locate event.basic_block, (b) =>
        @instructions[i].link @blocks[b], event.index

  removeInstruction: (event) ->
    @instructionsMap.locate event.name, (i) =>
      @instructions[i].unlink()

  transformStart: (event) ->