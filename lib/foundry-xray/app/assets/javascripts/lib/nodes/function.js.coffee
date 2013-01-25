class @FunctionNode
  constructor: (@name, @present) ->
    console.log [@name, @present]
    @arguments = []

  setArguments: (@arguments) ->

  setReturnType: (@type) ->

  title: ->
    template = if @present then 'nodes/function' else 'nodes/function_removed'

    JST[template]
      type: @type?.title() || '?'
      name: @name
      arguments: @arguments.map((x) -> x.title()).join(', ')