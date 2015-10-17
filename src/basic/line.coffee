# Static line chart implementation (using d3).
class Epoch.Chart.Line extends Epoch.Chart.Plot
  constructor: (@options={}) ->
    @options.type ?= 'line'
    super(@options)
    @draw()

  # @return [Function] The line generator used to construct the plot.
  line: (layer) ->
    [x, y] = [@x(), @y(layer.range)]
    d3.svg.line()
      .x((d) -> x(d.x))
      .y((d) -> y(d.y))

  # Draws the line chart.
  draw: ->
    [x, y, layers] = [@x(), @y(), @getVisibleLayers()]

    # Zero visible layers, just drop all and get out
    if layers.length == 0
      return @g.selectAll('.layer').remove()

    # 1) Join
    layer = @g.selectAll('.layer')
      .data(layers, (d) -> d.category)

    # 2) Update (only existing)
    layer.select('.line').transition().duration(500)
      .attr('d', (l) => @line(l)(l.values))

    # 3) Enter (Create)
    layer.enter().append('g')
      .attr('class', (l) -> l.className)
      .append('path')
        .attr('class', 'line')
        .attr('d', (l) => @line(l)(l.values))

    # 4) Update (existing & new)
    # Nuuupp

    # 5) Exit (Remove)
    layer.exit().transition().duration(750)
      .style('opacity', '0')
      .remove()

    super()
