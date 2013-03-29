#
# Internal representation of input JSON
#
class @Input
  @normalize: (@events) =>
    @functions = []
    events     = Object.extended()
    transforms = Object.extended()

    @events.each (event, i) =>
      if event['kind'] == 'transform'
        f = event['function_id']

        transforms[f] ||= []
        transforms[f].push
          id: events[f].length - 1
          label: event['name']
      else
        node = Node.refresh(event)
        
        if node.attachedFunctions?
          Object.each node.attachedFunctions(), (id, f) =>
            events[id] ||= []
            events[id].push i

    Node.kinds['function'].each (f) =>
      @functions.push
        name: f.name
        present: f.present
        input: new Input(f, events[f.id], transforms[f.id])

  @constantize: (kind) ->
    result = window[kind.camelize()+'Node']
    result

  constructor: (@function, @events, @transforms) ->
    @transforms = @transforms.filter (x, i) =>
      x.length = (@transforms[i+1]?.id || @events.length) - x.id
      x.id < @events.length-1 && x.length > 0

    @reset()

  activeBlocks: ->
    data = @kinds['basic_block']?.findAll (b) =>
      b.attachedFunctions()[@function.id]?

    data || []

  reset: ->
    @map    = Object.extended()
    @kinds  = Object.extended()
    @cursor = 0

    # run upcoming steps at initialization
    i = -1; @run(i) while (i+=1) < @events[0]

  rewind: (to) ->
    return if to == @cursor

    if to < @cursor
      delete @previousState
    else
      @previousState = new InputState(@)

    @reset()
    @increment(to)

  increment: (to) ->
    to   = @events.length-1 unless to?
    stop = [to, @events.length-1].min()
    stop = 0 if stop < 0

    i = @events[@cursor]; @run(i) while (i+=1) <= @events[stop]
    @cursor = stop

  run: (step) ->
    node = Node.refresh(Input.events[step], @map, @kinds)
