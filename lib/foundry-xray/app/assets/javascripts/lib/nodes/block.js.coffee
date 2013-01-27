class @BlockNode
  constructor: (@name, @instructions) ->
    @instructions ||= []

  title: (previousState) ->
    JST['nodes/block']
      name: @name
      instructions: @titleizeInstructions(previousState)

  titleizeInstructions: (previousState) ->
    unless previousState
      result = ""

      @instructions.each (x) -> 
        result += JST['nodes/diff/unchanged_line'] line: x.title()

      result
    else
      result    = ""
      removed   = Object.extended()
      added     = Object.extended()
      changed   = Object.extended()
      unchanged = Object.extended()

      previousState.each (ps, i) =>
        if !@instructions.any((cs) -> ps.name == cs.name)
          removed[i] = ps.title

      @instructions.each (cs, i) =>
        previous = previousState.find (ps) -> ps.name == cs.name
        currentTitle = cs.title()

        if previous && previous.title == currentTitle
          unchanged[i] = previous.title
        else if previous
          changed[i] = [previous.title, currentTitle]
        else
          added[i] = currentTitle

      [@instructions.length, previousState.length].max().times (i) ->
        result += JST['nodes/diff/removed_line'](line: removed[i]) if removed[i]
        result += JST['nodes/diff/added_line'](line: added[i]) if added[i]
        result += JST['nodes/diff/changed_line'](before: changed[i][0], after:changed[i][1]) if changed[i]
        result += JST['nodes/diff/unchanged_line'](line: unchanged[i]) if unchanged[i]

      result

  previous: ->
    try
      previous = @input.previous.blocks[@input.previous.blocksMap.find(@name)]
    catch error
      console.log error

    previous

  setName: (name) ->
    @name = name

  addInstruction: (instruction, index) ->
    @instructions.splice index, 0, instruction

  removeInstruction: (instruction) ->
    index = @instructions.findIndex(instruction)
    @instructions.splice index, 1 unless index < 0

  references: ->
    @instructions.last()?.operands.findAll((x) -> x.kind == "basic_block").map((x) -> x.name) || []