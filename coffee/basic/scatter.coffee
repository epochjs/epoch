
# Static scatter plot implementation (using d3).
class Epoch.Chart.Scatter extends Epoch.Chart.Plot
  defaults =
    radius: 3.5
    axes: ['top', 'bottom', 'left', 'right']

  # Creates a new scatter plot.
  # @param [Object] options Options for the plot.
  # @option options [Number] radius The default radius to use for the points in the plot (default 3.5). This can be overrwitten by individual points.
  constructor: (@options={}) ->
    super(@options = Epoch.Util.defaults(@options, defaults))

  # Draws the scatter plot.
  draw: ->
    super()

    [x, y] = [@x(), @y()]
    radius = @options.radius

    layer = @svg.selectAll('.layer')
      .data(@data, (d) -> d.category)

    layer.enter().append('g')
      .attr('class', (d) -> d.className)

    dots = layer.selectAll('.dot')
      .data((l) -> l.values)

    dots.transition().duration(500)
      .attr("r", (d) -> d.r ? radius)
      .attr("cx", (d) -> x(d.x))
      .attr("cy", (d) -> y(d.y))

    dots.enter().append('circle')
      .attr('class', 'dot')
      .attr("r", (d) -> d.r ? radius)
      .attr("cx", (d) -> x(d.x))
      .attr("cy", (d) -> y(d.y))

    dots.exit().transition()
      .duration(750)
      .style('opacity', 0)
      .remove()

    layer.exit().transition()
      .duration(750)
      .style('opacity', 0)
      .remove()
