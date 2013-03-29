class @ArgumentNode extends Node
  update: (data, map) ->
    @name = data['name']
    @type = @locate(data['type'], map)

  title: ->
    JST['nodes/argument']
      type: @type.title()
      name: @name

  operandTitle: ->
    JST['nodes/operands/argument']
      type: @type.title()
      name: @name