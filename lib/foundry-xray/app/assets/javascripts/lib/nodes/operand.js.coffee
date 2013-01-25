class @OperandNode

  constructor: (@kind, @type, @name, @value) ->

  title: ->
    switch @kind
      when 'argument'    then JST['nodes/operand_argument'] name: @name
      when 'instruction' then JST['nodes/operand_instruction'] name: @name
      when 'basic_block' then JST['nodes/operand_basic_block'] name: @name
      when 'constant' 
        JST['nodes/operand_constant']
          type: @type.title()
          value: @value