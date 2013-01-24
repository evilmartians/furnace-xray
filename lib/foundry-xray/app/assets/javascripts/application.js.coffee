#= require vendor/d3.v3
#= require vendor/dagre
#= require vendor/jquery
#= require vendor/ui.jquery
#= require vendor/sugar-1.3.8
#= require vendor/stacktrace-0.4
#= require vendor/chosen.jquery
#= require vendor/qtip.jquery
#= require_tree ./lib
#= require_self

$ -> window.app = new Application

class Application

  constructor: ->
    @data = window.data

    @toolbar  = $('#toolbar')
    @title    = $('#title')
    @selector = $('#functions select')

    @container   = $('#container')
    @timeline    = $('#timeline')
    @slider      = $('#timeline .slider')
    @sliderInput = $('#timeline input')
    @sliderApply = $('#timeline button.ok')
    @sliderNext  = $('#timeline button.next')
    @sliderPrev  = $('#timeline button.prev')
    @transforms  = $('#transforms')


    @currentFunction = 0
    @currentStep     = undefined

    @setupContainer()
    @buildSelector()
    @buildSlider()

    @draw()

  draw: ->
    try
      @timeline.show()

      input = @data[@currentFunction]

      Drawer.reset() if @input?.source.name != input.source.name
      Drawer.clear()

      @input = input
      @input.rebuild(@currentStep)
      @drawer = new Drawer(new Graph(@input))

      @renewSlider()
      @title.removeClass('error').html @input.function.title()
    catch error
      console.log error
      @timeline.hide()
      @title.addClass('error').text 'Unable to build graph: problem dumped to console'

  renewSlider: (max, value) ->
    @slider.slider
      max: @input.events.length-1
      value: @input.stop

    @slider.find('.label').remove()

    @input.transforms.each (entry) =>
      height = entry.length/(@input.events.length-1)*100
      top    = 100-entry.id/(@input.events.length-1)*100-height
      label  = "#{entry.label}&nbsp;(#{entry.id}+#{entry.length})"

      @transforms.append $("<div class='label'><span>#{label}</span></div>")
        .attr("style", "top: #{top}%; height: #{height}%;")
        .click (e) =>
          e.stopPropagation()
          @currentStep = entry.id
          @draw()

  setupContainer: ->
    resize = => 
      @container.find('.stretch').height($(window).height() - @toolbar.outerHeight() - 4)
      @slider.height($(window).height() - @toolbar.outerHeight() - 300)

    resize() && $(window).bind('resize', resize)

  buildSelector: ->
    @data.each (f, i) =>
      @selector.append "<option value='#{i}'>#{f.source.name}</option>"

    @selector.chosen().change =>
      @currentFunction = @selector.val().toNumber()
      @currentStep = undefined
      @draw()

  buildSlider: ->
    input = @sliderInput

    $('button').button()

    @slider.slider
      min: 0
      orientation: 'vertical'
      change: -> input.val $(@).slider('value')

    @slider.on 'mouseenter', '.label', -> $(this).find('span').show()
    @slider.on 'mouseout', '.label', -> $(this).find('span').hide()

    @sliderApply.click =>
      @currentStep = input.val().toNumber()
      @draw()

    @sliderPrev.click =>
      @currentStep = input.val().toNumber()-1
      @draw()

    @sliderNext.click =>
      @currentStep = input.val().toNumber()+1
      @draw()
