# Static bar chart implementation (using d3).
class Epoch.Chart.Bar extends Epoch.Chart.Plot
  defaults =
    style: 'grouped'
    orientation: 'horizontal'

  vertical_defaults =
    style: 'grouped'
    orientation: 'horizontal'
    tickFormats:
      top: Epoch.Formats.si
      bottom: Epoch.Formats.si
      left: Epoch.Formats.regular
      right: Epoch.Formats.regular

  constructor: (@options={}) ->
    if @options.orientation == 'vertical'
      @options = Epoch.Util.defaults(@options, vertical_defaults)
    else
      @options = Epoch.Util.defaults(@options, defaults)
    super(@options)

  # @return [Function] The scale used to generate the chart's x scale.
  x: ->
    if @options.orientation == 'horizontal'
      d3.scale.ordinal()
        .domain(Epoch.Util.domain(@data))
        .rangeRoundBands([0, @innerWidth()], .1)
    else
      extent = @extent((d) -> d.y)
      extent[0] = Math.min(0, extent[0])
      d3.scale.linear()
        .domain(extent)
        .range([0, @width - @margins.left - @margins.right])

  # @return [Function] The x scale used to render the horizontal bar chart.
  x1: (x0) ->
    d3.scale.ordinal()
      .domain((layer.category for layer in @data))
      .rangeRoundBands([0, x0.rangeBand()], .08)

  # @return [Function] The y scale used to render the bar chart.
  y: ->
    if @options.orientation == 'horizontal'
      extent = @extent((d) -> d.y)
      extent[0] = Math.min(0, extent[0])
      d3.scale.linear()
        .domain(extent)
        .range([@height - @margins.top - @margins.bottom, 0])
    else
      d3.scale.ordinal()
        .domain(Epoch.Util.domain(@data))
        .rangeRoundBands([0, @innerHeight()], .1)

  # @return [Function] The x scale used to render the vertical bar chart.
  y1: (y0) ->
    d3.scale.ordinal()
      .domain((layer.category for layer in @data))
      .rangeRoundBands([0, y0.rangeBand()], .08)

  # Remaps the bar chart data into a form that is easier to display.
  # @return [Array] The reorganized data.
  _remapData: ->
    map = {}
    for layer in @data
      className = 'bar ' + layer.className.replace(/\s*layer\s*/, '')
      for entry in layer.values
        map[entry.x] ?= []
        map[entry.x].push { label: layer.category, y: entry.y, className: className }
    ({group: k, values: v} for k, v of map)

  # Draws the bar char.
  draw: ->
    if @options.orientation == 'horizontal'
      @_drawHorizontal()
    else
      @_drawVertical()
    super()

  # Draws the bar chart with a horizontal orientation
  _drawHorizontal: ->
    [x0, y] = [@x(), @y()]
    x1 = @x1(x0)
    height = @height - @margins.top - @margins.bottom
    data = @_remapData()

    # 1) Join
    layer = @svg.selectAll(".layer")
      .data(data, (d) -> d.group)

    # 2) Update
    layer.transition().duration(750)
      .attr("transform", (d) -> "translate(#{x0(d.group)}, 0)")

    # 3) Enter / Create
    layer.enter().append("g")
      .attr('class', 'layer')
      .attr("transform", (d) -> "translate(#{x0(d.group)}, 0)")

    rects = layer.selectAll('rect')
      .data((group) -> group.values)

    rects.transition().duration(600)
      .attr('x', (d) -> x1(d.label))
      .attr('y', (d) -> y(d.y))
      .attr('width', x1.rangeBand())
      .attr('height', (d) -> height - y(d.y))

    rects.enter().append('rect')
      .attr('class', (d) -> d.className)
      .attr('x', (d) -> x1(d.label))
      .attr('y', (d) -> y(d.y))
      .attr('width', x1.rangeBand())
      .attr('height', (d) -> height - y(d.y))

    rects.exit().transition()
      .duration(150)
      .style('opacity', '0')
      .remove()

    # 4) Update new and existing

    # 5) Exit / Remove
    layer.exit()
      .transition()
      .duration(750)
      .style('opacity', '0')
      .remove()

  # Draws the bar chart with a horizontal orientation
  _drawVertical: ->
    [x, y0] = [@x(), @y()]
    y1 = @y1(y0)
    width = @width - @margins.left - @margins.right
    data = @_remapData()

    # 1) Join
    layer = @svg.selectAll(".layer")
      .data(data, (d) -> d.group)

    # 2) Update
    layer.transition().duration(750)
      .attr("transform", (d) -> "translate(0, #{y0(d.group)})")

    # 3) Enter / Create
    layer.enter().append("g")
      .attr('class', 'layer')
      .attr("transform", (d) -> "translate(0, #{y0(d.group)})")

    rects = layer.selectAll('rect')
      .data((group) -> group.values)

    rects.transition().duration(600)
      .attr('x', (d) -> 0)
      .attr('y', (d) -> y1(d.label))
      .attr('height', y1.rangeBand())
      .attr('width', (d) -> x(d.y))

    rects.enter().append('rect')
      .attr('class', (d) -> d.className)
      .attr('x', (d) -> 0)
      .attr('y', (d) -> y1(d.label))
      .attr('height', y1.rangeBand())
      .attr('width', (d) -> x(d.y))

    rects.exit().transition()
      .duration(150)
      .style('opacity', '0')
      .remove()

    # 4) Update new and existing

    # 5) Exit / Remove
    layer.exit()
      .transition()
      .duration(750)
      .style('opacity', '0')
      .remove()
