class @Node
  @refresh: (data, map=false, kinds=false) ->
    Node.map   ||= Object.extended()
    Node.kinds ||= Object.extended()

    map   ||= Node.map
    kinds ||= Node.kinds

    if map[data.id]
      map[data.id].update(data, map)
    else
      klass = window[data.kind.camelize()+'Node']

      return false if !klass?

      kinds[data.kind] ||= []
      kinds[data.kind].push map[data.id] = new klass(data, map)

    map[data.id]

  @reset: ->
    Node.map = Object.extended()
    Node.kinds = {}

  constructor: (data, map) ->
    @id = data.id
    @update(data, map)

  update: (data, map) ->

  locate: (id, map) ->
    map[id] || throw("Element #{id} not found in map")

  reassign: (before, after, callback) ->
    if !before? || before.length == 0
      callback([], after)
    else
      intersection = before.intersect(after)
      callback before.subtract(intersection), after.subtract(intersection)