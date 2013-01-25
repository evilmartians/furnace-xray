class @TypeNode

  constructor: (@kind, @name, @parameters) ->

  title: ->
    switch @kind
      when 'void' then JST['nodes/type_constant'](type: 'void')
      when 'monotype' then JST['nodes/type_constant'](type: @name)
      when 'parametric'
        JST['nodes/type_parametric']
          type: @name
          parameters: @parameters.map((x) -> x.title()).join(', ')