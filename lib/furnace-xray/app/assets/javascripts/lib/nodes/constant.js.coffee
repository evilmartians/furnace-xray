class @ConstantNode extends Node
  update: (data, map) ->
    @value = data['value']
    @type  = @locate(data['type'], map)

  operandTitle: ->
    JST['nodes/operands/constant']
      type: @type.title()
      value: @value