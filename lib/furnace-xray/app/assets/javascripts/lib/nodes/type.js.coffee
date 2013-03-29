class @TypeNode extends Node

  update: (data, map) ->
    @name = data['name']

  void: () -> false

  title: ->
    JST['nodes/type'](type: @name)