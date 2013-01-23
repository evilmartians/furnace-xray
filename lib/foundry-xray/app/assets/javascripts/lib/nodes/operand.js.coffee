class @OperandNode

  constructor: (@kind, @type, @name, @value) ->

  title: ->
    switch @kind
      when 'constant' then "#{@type} #{@value}"
      when 'instruction' then "%#{@name}"
      when 'basic_block' then "label %#{@name}"