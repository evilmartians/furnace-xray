class @FunctionNode extends Node
  update: (data, map) ->
    @name    = data['name']
    @type    = @locate(data['return_type'], map)
    @present = false

    @arguments = data['argument_ids'].map (id) => @locate(id, map)

    @reassign @blockIds, data['basic_block_ids'], (removed, added) =>
      removed.each (id) => @locate(id, map).unlinkFunction(@)
      added.each   (id) => @locate(id, map).linkFunction(@)

    @blockIds = data['basic_block_ids']
    @blocks = @blockIds.map (id) => @locate(id, map)

  linkModule:   -> @present = true
  unlinkModule: -> @present = false

  attachedFunctions: ->
    result = {}
    result[@id] = @
    result

  title: ->
    template = if @present then 'nodes/function' else 'nodes/function_removed'

    JST[template]
      type: @type?.title() || '?'
      name: @name
      arguments: @arguments.map((x) -> x.title()).join(', ')