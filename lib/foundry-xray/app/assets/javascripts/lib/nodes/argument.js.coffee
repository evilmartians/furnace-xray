class @ArgumentNode
  constructor: (@name, @type) ->

  title: ->
    JST['nodes/argument']
      type: @type.title()
      name: @name