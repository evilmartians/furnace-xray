#= require_tree ./vendor
#= require_tree ./lib
#= require_self

$ ->
  $('.loading-screen ').fadeOut(300)

  window.input = new Input window.data[1]
  window.drawer = new Drawer(input)