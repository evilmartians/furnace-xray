class @OperandNode

  constructor: (@kind, @type, @name, @value) ->

  title: ->
    switch @kind
      when 'argument'    then JST['nodes/operand_argument'] name: @name
      when 'instruction' then JST['nodes/operand_instruction'] name: @name
      when 'basic_block' then JST['nodes/operand_basic_block'] name: @name
      when 'constant'
        data =
          type: @type.title()
          value: @value

        if @type.name == 'function'
          template = 'operand_constant_function'
          data.parsedValue = JSON.parse(@value)
        else
          template = 'operand_constant'

        JST["nodes/#{template}"] data
