#= require vendor/d3.v3
#= require vendor/dagre
#= require vendor/jquery
#= require vendor/sugar-1.3.8
#= require vendor/stacktrace-0.4
#= require_tree ./lib
#= require_self

$ ->
  resize = ->
    $('svg').height -> $('html').height() - $('#toolbar').outerHeight()

  resize() && $(window).bind 'resize', resize

  window.input = new Input window.data[0]
  window.input.rebuild()

  window.drawer = new Drawer(new Graph(input))