#
# Maps internal JSON representation to a flat
# graph structure consumable by `Drawer`
#
class @Graph
  constructor: (@input) ->

    @edges     = []
    blockNodes = Object.extended()

    @input.activeBlocks()?.each (b) =>
      blockNodes[b.id] =
        edges: b.references()
        label: b.name
        data: b.title(unless @input.previousState? then false else (@input.previousState.basicBlocks[b.id] || []))

    blockNodes.each (i, n) =>
      edges = []

      n.edges.each (x) =>
        if blockNodes[x]?
          edges.add {source: n, target: blockNodes[x], data: blockNodes[x].label}
          @edges.add edges.last()

      n.edges = edges

    @nodes = blockNodes.values()