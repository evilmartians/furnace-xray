#
# Failsafe Map container
#
class @Map
  constructor: (@title) ->
    @data = []
    @map  = Object.extended()

  each: (block) -> @map.each block

  add: (name, block) ->
    id = @map[name]

    unless id?
      @data.add name
      id = @data.length-1
      block(id) if block
      @map[name] = id
    
    id

  find: (name) ->
    id = @map[name]

    unless id?
      error = "Map '#{@title}': '#{name}' element not found"
      throw error

    id

  remove: (name, block) ->
    id = @find(name)
    @data.splice id, 1
    block(id) if block
    delete @map[name]

  rename: (name, newName, block) ->
    id = @find(name)
    @data[id] = newName
    block(id) if block
    delete @map[name]
    @map[newName] = id

  locate: (name, block) ->
    block(@find(name))

  locateOrAdd: (name, block) ->
    block(@add(name))
