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
    if @opcode == 'phi'
      operands = []

      for x in [0..@operands.length-1] by 2
        do (x) =>
          operands.add("#{@operands[x].title()} => #{@operands[x+1].title()}") 
    else
      operands = @operands.map (x) -> x.title()

    if @type.kind == 'void'
      "#{@opcode} #{@parameters} #{operands.join(', ')}"
    else
      "#{@type.title()} %#{@name} = #{@opcode} #{@parameters} #{operands.join(', ')}"