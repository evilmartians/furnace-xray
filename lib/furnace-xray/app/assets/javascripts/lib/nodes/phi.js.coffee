class @PhiNode extends InstructionNode

  updateOperands: (data, map) ->
    @operands = data.map (pair) =>
      pair.map (x) =>
        @locate(x, map)

  titleizeOperands: (data) ->
    return "<DETACHED>" unless @operands
    @operands.map (pair) => "#{pair[0].operandTitle()} => #{pair[1].operandTitle()}"