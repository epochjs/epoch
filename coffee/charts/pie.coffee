# Basic Pie Chart  
class Epoch.Chart.Pie extends Epoch.Chart.SVG
  defaults =
    margin: 10
    inner: 0

  constructor: (@options={}) ->
    super(@options = Epoch.Util.defaults(@options, defaults))
    radius = Math.max(@width, @height) / 2
    @pie = d3.layout.pie().sort(null)
      .value (d) -> d.value
    @arc = d3.svg.arc()
      .outerRadius(radius - @options.margin)
      .innerRadius(@options.inner)
    @svg = @svg.append('g')
      .attr("transform", "translate(#{@width/2}, #{@height/2})")

  draw: ->
    arcs = @svg.selectAll(".arc")
      .data(@pie(@data), (d) -> d.data.label)

    arcs.enter().append('g')
      .attr('class', (d) -> "arc pie " + d.data.className)

    arcs.select('path')
      .attr('d', @arc)

    arcs.select('text')
      .attr("transform", (d) => "translate(#{@arc.centroid(d)})")
      .text((d) -> d.data.label)

    path = arcs.append("path")
      .attr("d", @arc)
      .each((d) -> @._current = d)

    text = arcs.append("text")
      .attr("transform", (d) => "translate(#{@arc.centroid(d)})")
      .attr("dy", ".35em")
      .style("text-anchor", "middle")
      .text((d) -> d.data.label)

    arcs.exit().remove()