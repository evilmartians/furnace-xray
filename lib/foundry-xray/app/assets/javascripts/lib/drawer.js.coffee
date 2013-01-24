#
# Draws `Graph`
# Dagre + D3.js wrapper
#
class @Drawer

  @container: ->
    @svg ||= d3.select("svg")

    unless @group?
      @group = @svg.append("g").attr("class", "container")

      zoom = d3.behavior.zoom().on "zoom", =>
          t = d3.event.translate
          s = d3.event.scale
          @group.attr("transform", "translate(" + t + ") scale(" + s + ")");

      @svg.call zoom

    @group

  @clear: ->
    @group?.select("g").remove()

  @reset: ->
    @group?.remove()
    delete @group

  constructor: (@graph, padding=10) ->
    @padding = padding

    @setupEntities()
    @draw()

  setupEntities: ->
    @container = @constructor.container().append("g").attr("transform", "translate(20, 20)")

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
    @assignTextLabels(@edges, 2) 

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
    labels.append("xhtml:div").style
      "float": "left"
      "white-space": "nowrap"

    labels.select("div")
      .html((d) -> d.data)
      .each (d) ->
        d.width = @clientWidth;
        d.height = @clientHeight;
        d.nodePadding = 0;

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