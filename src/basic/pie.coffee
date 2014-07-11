
# Static Pie Chart implementation (using d3).
class Epoch.Chart.Pie extends Epoch.Chart.SVG
  defaults =
    margin: 10
    inner: 0

  # Creates a new pie chart.
  # @param [Object] options Options for the pie chart.
  # @option options [Number] margin Margins to add around the pie chart (default: 10).
  # @option options [Number] inner The inner radius for the chart (default: 0).
  constructor: (@options={}) ->
    super(@options = Epoch.Util.defaults(@options, defaults))
    radius = Math.max(@width, @height) / 2
    @pie = d3.layout.pie().sort(null)
      .value (d) -> d.value
    @arc = d3.svg.arc()
      .outerRadius(radius - @options.margin)
      .innerRadius(@options.inner)
    @g = @svg.append('g')
      .attr("transform", "translate(#{@width/2}, #{@height/2})")

  # Draws the pie chart
  draw: ->
    @g.selectAll('.arc').remove()

    arcs = @g.selectAll(".arc")
      .data(@pie(@data), (d) -> d.data.category)

    arcs.enter().append('g')
      .attr('class', (d) -> "arc pie " + d.data.className)

    arcs.select('path')
      .attr('d', @arc)

    arcs.select('text')
      .attr("transform", (d) => "translate(#{@arc.centroid(d)})")
      .text((d) -> d.data.label or d.data.category)

    path = arcs.append("path")
      .attr("d", @arc)
      .each((d) -> @._current = d)

    text = arcs.append("text")
      .attr("transform", (d) => "translate(#{@arc.centroid(d)})")
      .attr("dy", ".35em")
      .style("text-anchor", "middle")
      .text((d) -> d.data.label or d.data.category)

    super()
