
# Static stacked area chart implementation using d3.
class Epoch.Chart.Area extends Epoch.Chart.Plot
  constructor: (@options={}) ->
    @options.type ?= 'area'
    super(@options)
    @draw()

  # Generates a scale needed to appropriately render the stacked visualization.
  # @return [Function] The y scale for the visualization.
  y: ->
    a = []
    for layer in @getVisibleLayers()
      for own k, v of layer.values
        a[k] += v.y if a[k]?
        a[k] = v.y unless a[k]?
    d3.scale.linear()
      .domain(@options.range ? [0, d3.max(a)])
      .range([@height - @margins.top - @margins.bottom, 0])

  # Renders the SVG elements needed to display the stacked area chart.
  draw: ->
    [x, y, layers] = [@x(), @y(), @getVisibleLayers()]

    @g.selectAll('.layer').remove()
    return if layers.length == 0

    area = d3.svg.area()
      .x((d) -> x(d.x))
      .y0((d) -> y(d.y0))
      .y1((d) -> y(d.y0 + d.y))

    stack = d3.layout.stack()
      .values((d) -> d.values)

    data = stack layers

    layer = @g.selectAll('.layer')
      .data(layers, (d) -> d.category)

    layer.select('.area')
      .attr('d', (d) -> area(d.values))

    layer.enter().append('g')
      .attr('class', (d) -> d.className)

    layer.append('path')
      .attr('class', 'area')
      .attr('d', (d) -> area(d.values))

    super()
