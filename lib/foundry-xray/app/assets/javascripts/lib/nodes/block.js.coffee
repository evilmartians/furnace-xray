class @BlockNode
  constructor: (@name) ->
    @instructions = []

  title: ->
    @name

  setName: (name) ->
    @name = name

  addInstruction: (instruction, index) ->
    @instructions.splice index, 0, instruction

  removeInstruction: (instruction) ->
    @instructions.splice @instructions.findIndex(instruction), 1