#
# Graph drawing routines.
# Drawer manages SVG canvas exclusively – avoid interferention
#
class @Drawer

  @canvasPadding = 20

  @attach: (selector) ->
    @svg   = d3.select(selector)
    @group = @svg.append("g").attr("class", "container")
    @zoom  = d3.behavior.zoom()

    @zoom.on "zoom", =>
      @group.attr("transform", "translate(#{d3.event.translate}) scale(#{d3.event.scale})")

    @svg.call(@zoom).on("dblclick.zoom", null)

  @zoomTo: (t, s) ->
    @zoom.translate(t)
    @zoom.scale(s) if s
    @group.attr("transform", "translate(#{t}) scale(#{s || @zoom.scale()})")

  @clear: ->
    @group?.select("g").remove()

  @reset: ->
    @zoomTo [@canvasPadding, @canvasPadding]

  constructor: (@graph, padding=10) ->
    @padding = padding

    @setupEntities()
    @draw()

  repaint: ->
    @container.attr("transform", "translate(0,1)")
    @container.attr("transform", "translate(0,0)")

  fit: (width, height) ->
    @zoomValue = [@constructor.zoom.translate(), @constructor.zoom.scale()]

    width  = (width-@constructor.canvasPadding*2) / @width()
    height = (height-@constructor.canvasPadding*2) / @height()
    ratio  = [width, height].min()

    @constructor.zoomTo([@constructor.canvasPadding,@constructor.canvasPadding], ratio)

  unfit: ->
    @constructor.zoomTo @zoomValue...

  zoomNode: (width, height, name) ->
    padding = @constructor.canvasPadding
    width   = width-padding*2
    height  = height-padding*2

    zoom = @constructor.zoom.scale()
    node = @container.select("#node-#{name}")
    bbox = node[0][0].getBBox()

    if width < bbox.width*zoom || height < bbox.height*zoom
      zoomTo = zoom = [width/bbox.width, height/bbox.height].min()

    x = (-node.attr("x").toNumber()*zoom+width/2-bbox.width*zoom/2)+padding
    y = (-node.attr("y").toNumber()*zoom+height/2-bbox.height*zoom/2)+padding

    @constructor.zoomTo [x, y], zoomTo

  setupEntities: ->
    @container = @constructor.group.append("g")

    # `nodes` is center positioned for easy layout later
    @nodes = @container.selectAll("g .node")
      .data(@graph.nodes)
      .enter()
      .append("g")
      .attr("class", "node")
      .attr("id", (d) -> "node-" + d.label)

    @edges = @container.selectAll("g .edge")
      .data(@graph.edges)
      .enter()
      .append("g")
      .attr("class", "edge")

    @edges
      .append("path")
      .attr("marker-end", "url(#arrowhead)")

    @assignHtmlLabels(@nodes)
    @assignTextLabels(@edges, 1) 

  assignTextLabels: (items, padding) ->
    groups = items.append("g").attr("class", "label")
    rects  = groups.append("rect")
    labels = groups.append("text")

    labels.attr("text-anchor", "left")
      .append("tspan")
      .attr("dy", "1em")
      .text((d) -> d.data)

    @setupEntitiesSizes(rects, labels, padding)

  assignHtmlLabels: (items, padding) ->
    groups = items.append("g").attr("class", "label")
    rects  = groups.append("rect")
    labels = groups.append("foreignObject")
    texts = labels.append("xhtml:div").style
      "float": "left"
      "white-space": "nowrap"

    texts.html((d) -> d.data).each (d) ->
      if @clientWidth > 900
        d3.select(@).style
          "white-space": "normal"
          "width": '900px'

    texts
      .each (d) ->
        d.width = @clientWidth
        d.height = @clientHeight
        d.nodePadding = 0

    labels
      .attr("width", (d) -> d.width)
      .attr("height", (d) -> d.height)

    @setupEntitiesSizes(rects, labels, padding)

  setupEntitiesSizes: (rects, labels, padding) ->
    padding = @padding unless padding

    # We need width and height for layout.
    labels.each (d) ->
      bbox = @getBBox()
      d.bbox = bbox
      d.width = bbox.width + 2 * padding
      d.height = bbox.height + 2 * padding

    rects
      .attr("width", (d) -> d.width)
      .attr("height", (d) -> d.height)

    labels
      .attr("x", (d) -> padding)
      .attr("y", (d) -> padding)

  width: -> @container[0][0].getBBox().width
  height: -> @container[0][0].getBBox().height

  draw: ->
    dagre.layout().nodeSep(50).edgeSep(50).rankSep(50)
      .nodes(@graph.nodes)
      .edges(@graph.edges)
      .run()

    # Positioning nodes
    @nodes.attr "transform", (d, i) =>
      x = d.dagre.x - d.width/2
      y = d.dagre.y - d.height/2

      @nodes[0][i].setAttribute 'x', x
      @nodes[0][i].setAttribute 'y', y

      "translate(#{x},#{y})"

    # Ensure that we have at least two points between source and target
    @edges.each (d) ->
      points = d.dagre.points
      unless points.length
        s = d.source.dagre
        t = d.target.dagre
        points.push
          x: (s.x + t.x) / 2
          y: (s.y + t.y) / 2

      if points.length is 1
        points.push
          x: points[0].x
          y: points[0].y

    # Setting correct path coordinates
    @edges.selectAll("path").attr "d", (e) ->
      points = e.dagre.points.slice(0)
      source = dagre.util.intersectRect(e.source.dagre, points[0])
      target = dagre.util.intersectRect(e.target.dagre, points[points.length - 1])

      points.unshift source
      points.push target

      d3.svg.line()
        .x((d) -> d.x)
        .y((d) -> d.y)
        .interpolate("linear")(points)

    # Positioning edges labels
    @edges.selectAll("g.label")
      .attr("transform", (d) ->
        points = d.dagre.points;
        x = (points[0].x + points[1].x) / 2;
        y = (points[0].y + points[1].y) / 2;
        return "translate(" + (-d.bbox.width / 2 + x) + "," + (-d.bbox.height / 2 + y) + ")";
      )