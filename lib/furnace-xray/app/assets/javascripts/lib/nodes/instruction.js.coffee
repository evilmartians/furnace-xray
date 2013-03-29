class @InstructionNode extends Node
  constructor: (data, map) ->
    super
    @blocks = Object.extended()

  linkBlock: (block) ->
    @blocks[block.id] = block
    @operands?.each (x) => x.linkBlock(block) if x['linkBlock']?

  unlinkBlock: (block) ->
    delete @blocks[block.id]
    @operands?.each (x) => x.unlinkBlock(block) if x['unlinkBlock']?

  attachedFunctions: ->
    result = {}
    @blocks.values().each (x) -> Object.merge result, x.attachedFunctions()
    result

  update: (data, map) ->
    @type       = @locate(data['type'], map)
    @name       = data['name']
    @opcode     = data['opcode']
    @parameters = data['parameters']

    if data['operand_ids']
      @updateOperands(data['operand_ids'], map)
    else
      @operands = null

  updateOperands: (data, map) ->
    @operands = data.map (x) => @locate(x, map)

  title: ->
    if @type && !@type.void()
      JST['nodes/instruction']
        type: @type.title()
        name: @name
        opcode: @opcode
        parameters: @parameters
        operands: @titleizeOperands()
    else
      JST['nodes/instruction_void']
        opcode: @opcode
        parameters: @parameters
        operands: @titleizeOperands()

  titleizeOperands: ->
    return "<DETACHED>" unless @operands
    @operands.map((x) -> x.operandTitle()).join(', ')

  operandTitle: ->
    JST['nodes/operands/instruction']
      name: @name