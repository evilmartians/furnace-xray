#= require vendor/d3.v3
#= require vendor/dagre
#= require vendor/jquery
#= require vendor/ui.jquery
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

  # Fill functions selector
  functionsSelector = $('#functions select')
  window.data.each (f, i) -> functionsSelector.append "<option value='#{i}'>#{f.name}</option>"
  functionsSelector.chosen()
  functionsSelector.change ->
    window.index = functionsSelector.val()
    draw()

  # Initialize slider
  $('#timeline .slider').slider()

  # Draw routine
  draw = ->
    try
      $('#timeline .message').hide()
      window.drawer?.clear()
      window.input = new Input window.data[window.index.toNumber()]
      window.input.rebuild()
      window.drawer = new Drawer(new Graph(input))
    catch error
      console.log error
      $('#timeline .select').hide()
      $('#timeline .message').show().text('Unable to build graph: problem dumped to console')
      $('#timeline .message').effect('shake', distance: 3, times: 2)

  # Start with firts function
  draw()