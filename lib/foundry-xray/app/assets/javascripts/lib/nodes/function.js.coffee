class @FunctionNode
  constructor: (@name) ->
    @arguments = []

  setArguments: (@arguments) ->

  setReturnType: (@type) ->

  title: ->
    "#{@type?.title?() || '?'} <b>#{@name}</b>(#{@arguments.map((x) -> x.title()).join(', ')})"