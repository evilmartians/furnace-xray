class @InputState
  constructor: (input) ->
    @blocks = Object.extended()

    input.blocksMap.each (bname, id) =>
      @blocks[bname] = input.blocks[id].instructions.map (x) ->
        {title: x.title(), name: x.name}