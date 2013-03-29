class @ModuleNode extends Node
  update: (data, map) ->
    @reassign @functionIds, data['function_ids'], (removed, added) =>
      removed.each (id) => @locate(id, map).unlinkModule(@)
      added.each   (id) => @locate(id, map).linkModule(@)

    @functionIds = data['function_ids']
    @functions  = @functionIds.map (id) => @locate(id, map)