class @InputState
  constructor: (input) ->
    @basicBlocks = Object.extended()
    @cursor = input.cursor

    input.kinds['basic_block']?.each (b) =>
      @basicBlocks[b.id] = b.instructions.map (i) =>
        id: i.id
        name: i.name
        title: i.title()