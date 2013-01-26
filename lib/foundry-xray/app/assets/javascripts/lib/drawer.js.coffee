#
# Graph drawing routines.
# Drawer manages SVG canvas exclusively – avoid interferention
#
class @Drawer

  @attach: (selector) ->
    @svg   = d3.select(selector)
    @group = @svg.append("g").attr("class", "container")
    @zoom  = d3.behavior.zoom()

    @zoom.on "zoom", =>
      @group.attr("transform", "translate(#{d3.event.translate}) scale(#{d3.event.scale})")

    @svg.call(@zoom).on("dblclick.zoom", null)

  @zoomTo: (t, s) ->
    @zoom.translate(t)
    @zoom.scale(s)
    @group.attr("transform", "translate(#{t}) scale(#{s})")

  @clear: ->
    @group?.select("g").remove()

  @reset: ->
    @zoomTo [10, 10], 1

  constructor: (@graph, padding=10) ->
    @padding = padding

    @setupEntities()
    @draw()

  fit: (width, height) ->
    @zoomValue = [@constructor.zoom.translate(), @constructor.zoom.scale()]

    width  = (width-20) / @width()
    height = (height-20) / @height()
    ratio  = [width, height].min()

    @constructor.zoomTo([10,10], ratio)

  unfit: ->
    @constructor.zoomTo @zoomValue...

  setupEntities: ->
    @container = @constructor.group.append("g")

    # `nodes` is center positioned for easy layout later
    @nodes = @container.selectAll("g .node")
      .data(@graph.nodes)
      .enter()
      .append("g")
      .attr("class", "node")
      #.attr("id", (d) -> "node-" + d.label)

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
      .attr("x", (d) -> -(d.bbox.width / 2 + padding))
      .attr("y", (d) -> -(d.bbox.height / 2 + padding))
      .attr("width", (d) -> d.width)
      .attr("height", (d) -> d.height)

    labels
      .attr("x", (d) -> -d.bbox.width / 2)
      .attr("y", (d) -> -d.bbox.height / 2)

  width: -> @container[0][0].getBBox().width
  height: -> @container[0][0].getBBox().height

  draw: ->
    dagre.layout().nodeSep(50).edgeSep(50).rankSep(50)
      .nodes(@graph.nodes)
      .edges(@graph.edges)
      .run()

    # Positioning nodes
    @nodes.attr "transform", (d) -> "translate(" + d.dagre.x + "," + d.dagre.y + ")"

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