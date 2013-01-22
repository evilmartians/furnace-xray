class @TypeNode

  constructor: (@kind, @name, @parameters) ->

  title: ->
    switch @kind
      when 'void' then 'void'
      when 'monotype' then @name
      when 'parametric' then "#{@name}<#{@parameters.map((x) -> x.title()).join(', ')}>"