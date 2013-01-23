class @Map
  constructor: ->
    @data = []

  add: (name, block) ->
    id = @data.findIndex(name)

    if id < 0
      @data.add name
      id = @data.length-1
      block(id) if block
    
    id

  find: (name) ->
    id = @data.findIndex(name)

    if id < 0 
      console.log printStackTrace()
      throw "Not found"

    id

  remove: (name, block) ->
    id = @find(name)
    @data.splice id, 1
    block(id) if block

  rename: (name, newName, block) ->
    id = @find(name)
    @data[id] = newName
    block(id) if block

  locate: (name, block) ->
    block(@find(name))