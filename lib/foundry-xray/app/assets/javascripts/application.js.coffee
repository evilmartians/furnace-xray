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

    Drawer.attach('svg')

    @toolbar   = $('#toolbar')
    @title     = $('#title')
    @transform = $('#transform')
    @selector  = $('#functions select')

    @zoomButton = $('#zoom button')

    @container   = $('#container')
    @svg         = $('svg')
    @timeline    = $('#timeline')
    @slider      = $('#timeline .slider')
    @sliderInput = $('#timeline input')
    @sliderApply = $('#timeline button.ok')
    @sliderNext  = $('#timeline button.next')
    @sliderPrev  = $('#timeline button.prev')
    @sliderFNext = $('#timeline button.fnext')
    @sliderFPrev = $('#timeline button.fprev')

    @transforms  = $('#transforms')

    @buildZoomer()
    @buildSelector()
    @buildSlider()

    redraw = =>
      @dehasherize()
      @currentFunction ||= 0
      @draw()

    redraw(); $(window).bind 'hashchange', redraw

    resize = => 
      @container.find('.stretch').height($(window).height() - @toolbar.outerHeight() - 4)
      @slider.height($(window).height() - @toolbar.outerHeight() - 280)

    resize(); $(window).bind('resize', resize)

  draw: ->
    try
      @timeline.show()
      @title.removeClass('error')
      @transform.removeClass('active').html('')

      input = @data[@currentFunction]

      Drawer.reset() if @input?.source.name != input.source.name
      Drawer.clear()

      @input = input
      @input.rebuild(@currentStep)
      @drawer = new Drawer(new Graph(@input))

      @renewZoomer()
      @renewSelector()
      @renewSlider()
      @renewNaming()

      @title.html @input.function.title()
    catch error
      console.log error
      @timeline.hide()
      @title.addClass('error').text 'Unable to build graph: problem dumped to console'

  dehasherize: ->
    hash = window.location.hash.from(1)
    hash = "0:#{@data[0].events.length-1}" if hash.length == 0
    [@currentFunction, @currentStep] = hash.split(":").map (x) -> x.toNumber()

  jumpTo: (func, step) ->
    if Object.isString(func)
      @selector.find('option').each (x) ->
        func = $(@).attr('value').toNumber() if $(@).text() == func

    @currentFunction = func; step = @data[func].events.length-1 if step == undefined
    @currentStep     = [step, @data[func].events.length-1].min()
    @currentStep     = [0, @currentStep].max()
    window.location.hash = "#{@currentFunction}:#{@currentStep || 0}"

  jumpToBlock: (name) ->
    @drawer.zoomNode @svg.width(), @svg.height(), name

  renewSlider: (max, value) ->
    @slider.slider
      max: @input.events.length-1
      value: @input.stop

    @slider.find('.label').remove()

    @input.transforms.each (entry) =>
      height = entry.length/(@input.events.length-1)*100
      top    = 100-entry.id/(@input.events.length-1)*100-height
      label  = "#{entry.label}&nbsp;(#{entry.id}+#{entry.length})"

      if @currentStep >= entry.id && @currentStep < entry.id+entry.length
        klass = "current"
        @transform.addClass('active').html(entry.label)
      else
        klass = ""

      @transforms.append $("<div class='label #{klass}'><span>#{label}</span></div>")
        .attr("style", "top: #{top}%; height: #{height}%;")
        .mousedown (e) =>
          e.stopPropagation()
          @jumpTo @currentFunction, entry.id

  renewSelector: ->
    @selector.val(@currentFunction).trigger('liszt:updated')

  renewZoomer: ->
    @zoomButton.removeClass 'active'

  renewNaming: ->
    elements = $('.naming')
    drawer   = @drawer

    elements.filter('.link').click ->
      element = $(@)
      active  = element.hasClass('active')
      needle  = element.attr("data-naming") || @innerHTML
      elements.removeClass('active')

      unless active
        elements.filter(->
          ($(@).attr("data-naming") || @innerHTML) == needle
        ).addClass('active')

      drawer.repaint()

  buildZoomer: ->
    @zoomButton.click =>
      if @zoomButton.hasClass('active')
        @zoomButton.removeClass('active')
        @drawer.unfit()
      else
        @zoomButton.addClass('active')
        @drawer.fit(@svg.width(), @svg.height())

  buildSelector: ->
    groups = ['Present', 'Removed'].map (x) -> $("<optgroup label='#{x}'></optgroup>")

    @data.each (f, i) =>
      group = if f.source.present then groups[0] else groups[1]
      group.append "<option value='#{i}'>#{f.source.name}</option>"

    groups.each (x) => @selector.append x

    @selector.chosen(search_contains: true).change => @jumpTo @selector.val().toNumber()
    @selector.val(@currentFunction).trigger('liszt:updated')

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
        @jumpTo @currentFunction, @sliderInput.val().toNumber() if event.originalEvent

    @slider.on 'mouseenter', '.label', -> $(this).find('span').show()
    @slider.on 'mouseout', '.label', -> $(this).find('span').hide()

    next = => @jumpTo @currentFunction, @currentStep+1
    prev = => @jumpTo @currentFunction, @currentStep-1

    fnext = =>
      step = @input.transforms.find (x) => x.id > @currentStep
      if step
        @jumpTo @currentFunction, step.id 
      else
        @jumpTo @currentFunction, @currentStep+1

    fprev = =>
      step = @input.transforms.findAll((x) => x.id < @currentStep).last()
      @jumpTo @currentFunction, step.id if step

    @sliderPrev.click prev
    @sliderNext.click next
    @sliderFNext.click fnext
    @sliderFPrev.click fprev

    $(document).bind 'keydown.h', fprev
    $(document).bind 'keydown.j', prev
    $(document).bind 'keydown.k', next
    $(document).bind 'keydown.l', fnext
    $(document).bind 'keydown.x', => @zoomButton.click()
    $(document).bind 'keydown.backspace', (e) ->
      e.preventDefault()
      history.back()