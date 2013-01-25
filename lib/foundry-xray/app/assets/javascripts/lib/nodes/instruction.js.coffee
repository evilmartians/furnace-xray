class @InstructionNode
  constructor: ->
    @blocks = []

  update: (@opcode, @name, @parameters, @operands, @type) ->

  link: (block, index) ->
    block.addInstruction(@, index)
    @blocks.add block

  unlink: ->
    @blocks.each (x) => x.removeInstruction(@)
    @blocks = []

  title: ->
    operands = @operands.map (x) ->
      if x instanceof OperandNode
        x.title()
      else
        "%#{x[0]} => #{x[1].title()}"

    if @type.kind == 'void'
      "<b>#{@opcode}</b> #{@parameters} #{operands.join(', ')}"
    else
      "#{@type.title()} %#{@name} = <b>#{@opcode}</b> #{@parameters} #{operands.join(', ')}"