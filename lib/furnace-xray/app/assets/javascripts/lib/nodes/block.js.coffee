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
      result += JST['nodes/diff/unchanged_line'] line: x.title() for x in @instructions 
      result
    else
      result    = ""
      removed   = Object.extended()
      added     = Object.extended()
      changed   = Object.extended()
      unchanged = Object.extended()

      for cs, i in @instructions
        previous = previousState.find (ps) -> ps.name == cs.name
        currentTitle = cs.title()

        if previous && previous.title == currentTitle
          unchanged[i] = previous.title
          previous.newPosition = i
        else if previous
          changed[i] = [previous.title, currentTitle]
          previous.newPosition = i
        else
          added[i] = currentTitle

      for ps, i in previousState
        if !ps.newPosition?
          position = 0

          while --i >= 0
            if previousState[i].newPosition?
              position = previousState[i].newPosition+1
              break

          removed[position] ||= []
          removed[position].push ps.title

      [@instructions.length, previousState.length].max().times (i) ->
        if removed[i]
          result += JST['nodes/diff/removed_line'](line: l) for l in removed[i]

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