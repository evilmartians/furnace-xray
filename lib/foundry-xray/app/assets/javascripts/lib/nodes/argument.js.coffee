class @ArgumentNode
  constructor: (@name, @type) ->

  title: ->
    "#{@type.title()} #{@name}"