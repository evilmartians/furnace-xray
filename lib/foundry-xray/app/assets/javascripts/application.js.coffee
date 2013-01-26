#= require vendor/d3.v3
#= require vendor/dagre
#= require vendor/jquery
#= require vendor/ui.jquery
#= require vendor/sugar-1.3.8
#= require vendor/stacktrace-0.4
#= require vendor/chosen.jquery
#= require vendor/mustache
#= require vendor/hotkeys.jquery
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
    @sliderFNext = $('#timeline button.fnext')
    @sliderFPrev = $('#timeline button.fprev')
    @transforms  = $('#transforms')

    @dehasherize()
    @currentFunction ||= 0
    @currentStep     ||= undefined

    @setupContainer()
    @buildSelector()
    @buildSlider()

    @draw(@currentStep)

  draw: (step) ->
    try
      @timeline.show()

      input = @data[@currentFunction]

      Drawer.reset() if @input?.source.name != input.source.name
      Drawer.clear()

      @input = input
      @input.rebuild(step)
      @drawer = new Drawer(new Graph(@input))

      @currentStep = @input.stop
      @hasherize()

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
      klass  = if @currentStep >= entry.id && @currentStep < entry.id+entry.length then "current" else ""

      @transforms.append $("<div class='label #{klass}'><span>#{label}</span></div>")
        .attr("style", "top: #{top}%; height: #{height}%;")
        .mousedown (e) =>
          e.stopPropagation()
          @draw entry.id

  setupContainer: ->
    resize = => 
      @container.find('.stretch').height($(window).height() - @toolbar.outerHeight() - 4)
      @slider.height($(window).height() - @toolbar.outerHeight() - 250)

    resize() && $(window).bind('resize', resize)

  hasherize: ->
    window.location.hash = "#{@currentFunction}:#{@currentStep}"

  dehasherize: ->
    [@currentFunction, @currentStep] = window.location.hash.from(1).split(":")

  buildSelector: ->
    groups = ['Present', 'Removed'].map (x) -> $("<optgroup label='#{x}'></optgroup>")

    @data.each (f, i) =>
      group = if f.source.present then groups[0] else groups[1]
      group.append "<option value='#{i}'>#{f.source.name}</option>"

    groups.each (x) => @selector.append x

    @selector.chosen(search_contains: true).change =>
      @currentFunction = @selector.val().toNumber()
      @draw()

  buildSlider: ->
    $('button').button()

    @sliderInput.focus -> $(@).blur()

    @slider.slider
      min: 0
      orientation: 'vertical'
      slide: (event, ui) => @sliderInput.val ui.value
      change: (event) =>
        @sliderInput.val @slider.slider('value')
        # Redraw if triggered by manual slider scroll
        @draw @sliderInput.val().toNumber() if event.originalEvent

    @slider.on 'mouseenter', '.label', -> $(this).find('span').show()
    @slider.on 'mouseout', '.label', -> $(this).find('span').hide()

    next = => @draw @currentStep-1
    prev = => @draw @currentStep+1

    fnext = =>
      step = @input.transforms.find (x) => x.id > @currentStep
      @draw step.id if step

    fprev = =>
      step = @input.transforms.findAll((x) => x.id < @currentStep).last()
      @draw step.id if step

    @sliderPrev.click next
    @sliderNext.click prev
    @sliderFNext.click fnext
    @sliderFPrev.click fprev

    $(document).add('.chzn-container input').bind 'keydown.h', fprev
    $(document).add('.chzn-container input').bind 'keydown.j', prev
    $(document).add('.chzn-container input').bind 'keydown.k', next
    $(document).add('.chzn-container input').bind 'keydown.l', fnext