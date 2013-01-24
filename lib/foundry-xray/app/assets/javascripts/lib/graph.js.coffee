#
# Maps internal JSON representation to a flat
# graph structure consumable by `Drawer`
#
class @Graph
  constructor: (@input) ->

    blockNodes = Object.extended()

    @input.blocks.each (i, b) ->
      blockNodes[b.name] =
        edges: b.references()
        label: b.name
        data: b.title()

    blockNodes.each (i, n) ->
      n.edges = n.edges.map((x) -> {source: n, target: blockNodes[x], data: blockNodes[x].label})

    @edges = []
    @nodes = blockNodes.values()

    @nodes.each (x) =>
      x.edges.each (y) =>
        @edges.add y