class @FunctionNode
  constructor: (@name) ->
    @arguments = []

  setArguments: (@arguments) ->

  setReturnType: (@type) ->

  title: ->
    JST['nodes/function']
      type: @type?.title() || '?'
      name: @name
      arguments: @arguments.map((x) -> x.title()).join(', ')