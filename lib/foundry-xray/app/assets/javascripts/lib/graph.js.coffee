#
# Maps internal JSON representation to a flat
# graph structure consumable by `Drawer`
#
class @Graph
  constructor: (@input) ->

    @edges     = []
    blockNodes = Object.extended()

    @input.blocks.each (i, b) ->
      blockNodes[b.name] =
        edges: b.references()
        label: b.name
        data: b.title()

    blockNodes.each (i, n) =>
      edges = []

      n.edges.each (x) =>
        edges.add {source: n, target: blockNodes[x], data: blockNodes[x].label}
        @edges.add edges.last()

      n.edges = edges

    @nodes = blockNodes.values()