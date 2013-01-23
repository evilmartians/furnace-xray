class @FunctionNode
  constructor: (@name, @events) ->
    @events.each (x) -> x.event = x.event.camelize(false)
    @arguments = []

  setArguments: (@arguments) ->

  setReturnType: (@type) ->

  title: ->
    "#{@type?.title()} <b>#{@name}</b>(#{@arguments.map((x) -> x.title()).join(', ')})"