class @BlockNode
  constructor: (@name) ->
    @instructions = []

  title: ->
    "<b>#{@name}</b>:<br/>" +
    "<blockquote>" + 
      @instructions.map((x) -> x.title()).join("<br/>") + 
    "</blockquote>"

  setName: (name) ->
    @name = name

  addInstruction: (instruction, index) ->
    @instructions.splice index, 0, instruction

  removeInstruction: (instruction) ->
    index = @instructions.findIndex(instruction)
    @instructions.splice index, 1 unless index < 0