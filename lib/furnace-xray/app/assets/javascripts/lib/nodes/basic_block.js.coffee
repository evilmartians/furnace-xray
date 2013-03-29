class @BasicBlockNode extends Node
  constructor: (data, map) ->
    super
    @functions = Object.extended()

  update: (data, map) ->
    @name = data['name']

    @reassign @instructionIds, data['instruction_ids'], (removed, added) =>
      removed.each (id) => @locate(id, map).unlinkBlock(@)
      added.each   (id) => @locate(id, map).linkBlock(@)

    @instructionIds = data['instruction_ids']
    @instructions   = @instructionIds.map (id) => @locate(id, map)

  linkFunction: (f) ->
    @functions[f.id] = f

  unlinkFunction: (f) ->
    delete @functions[f.id]

  attachedFunctions: -> @functions

  title: (previousInstructions) ->
    JST['nodes/block']
      name: @name
      instructions: @titleizeInstructions(previousInstructions)

  operandTitle: ->
    JST['nodes/operands/basic_block']
      name: @name

  titleizeInstructions: (previousInstructions) ->
    unless previousInstructions
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
        previous = previousInstructions.find (ps) -> ps.id == cs.id
        currentTitle = cs.title()

        if previous && previous.title == currentTitle
          unchanged[i] = previous.title
          previous.newPosition = i
        else if previous
          changed[i] = [previous.title, currentTitle]
          previous.newPosition = i
        else
          added[i] = currentTitle

      for ps, i in previousInstructions
        if !ps.newPosition?
          position = 0

          while --i >= 0
            if previousInstructions[i].newPosition?
              position = previousInstructions[i].newPosition+1
              break

          removed[position] ||= []
          removed[position].push ps.title

      [@instructions.length, previousInstructions.length].max().times (i) ->
        if removed[i]
          result += JST['nodes/diff/removed_line'](line: l) for l in removed[i]

        result += JST['nodes/diff/added_line'](line: added[i]) if added[i]
        result += JST['nodes/diff/changed_line'](before: changed[i][0], after:changed[i][1]) if changed[i]
        result += JST['nodes/diff/unchanged_line'](line: unchanged[i]) if unchanged[i]

      result

  references: ->
    ids = @instructions.last()?.operands.findAll((x) -> x instanceof BasicBlockNode).map((x) -> x.id)
    (ids || []).exclude((x) => x == @id)