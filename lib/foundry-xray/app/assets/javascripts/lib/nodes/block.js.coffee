class @BlockNode
  constructor: (@name) ->

  title: ->
    @name

  setName: (name) ->
    @name = name