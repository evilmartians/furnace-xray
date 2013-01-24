class @TypeNode

  constructor: (@kind, @name, @parameters) ->

  title: ->
    type = switch @kind
      when 'void' then 'void'
      when 'monotype' then @name
      when 'parametric' then "#{@name}<#{@parameters.map((x) -> x.title()).join(', ')}>"

    "<i class='type'>#{type}</i>"