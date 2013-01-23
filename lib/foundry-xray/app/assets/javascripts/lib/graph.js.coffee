#
# Maps internal JSON representation to a flat
# graph structure consumable by `Drawer`
#
class @Graph
  constructor: (@input) ->

    @edges = []
    # Function is our root node
    @nodes = [
      {
        edges: [],
        label: @input.function.title()
      }
    ]

    @input.blocks.each (i, b) =>
      @nodes.add
        edges: [],
        label: b.title()