#= require vendor/d3.v3
#= require vendor/dagre
#= require vendor/jquery
#= require vendor/sugar-1.3.8
#= require vendor/stacktrace-0.4
#= require vendor/chosen.jquery
#= require_tree ./lib
#= require_self

$ ->
  svg = $('svg')
  window.index = 0

  # Resize SVG canvas
  resize = -> svg.height $('html').height() - $('#toolbar').outerHeight()
  resize() && $(window).bind 'resize', resize

  # Draw routine
  draw = ->
    try
      $('#timeline').html ''

      window.drawer?.clear()
      window.input = new Input window.data[window.index.toNumber()]
      window.input.rebuild()
      window.drawer = new Drawer(new Graph(input))
    catch error
      console.log error
      $('#timeline').html '<div class="message">Unable to build graph: problem dumped to console</div>'

  # Fill functions selector
  functionsSelector = $('#functions select')
  window.data.each (f, i) -> functionsSelector.append "<option value='#{i}'>#{f.name}</option>"
  functionsSelector.chosen()
  functionsSelector.change ->
    window.index = functionsSelector.val()
    draw()

  # Start with firts function
  draw()