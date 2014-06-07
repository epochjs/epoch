# Static bar chart implementation (using d3).
class Epoch.Chart.Bar extends Epoch.Chart.Plot
  defaults = 
    style: 'grouped'

  constructor: (@options={}) ->
    super(@options = Epoch.Util.defaults(@options, defaults))

  # @return [Function] The scale used to generate the chart's x scale.
  x: ->
    d3.scale.ordinal()
      .domain(Epoch.Util.domain(@data))
      .rangeRoundBands([0, @innerWidth()], .1)

  # @return [Function] The x scale used to render the bar chart.
  x1: (x0) ->
    d3.scale.ordinal()
      .domain(((if d.label? then d.label else d._category) for d in @data))
      .rangeRoundBands([0, x0.rangeBand()], .08)

  # @return [Function] The y scale used to render the bar chart.
  y: ->
    extent = @extent((d) -> d.y)
    extent[0] = Math.min(0, extent[0])
    d3.scale.linear()
      .domain(extent)
      .range([@height - @margins.top - @margins.bottom, 0])

  # Remaps the bar chart data into a form that is easier to display.
  # @return [Array] The reorganized data.
  _remapData: ->
    map = {}
    for layer in @data
      className = 'bar ' + layer.className.replace(/\s*layer\s*/, '')
      for entry in layer.values
        map[entry.x] ?= []
        label = if layer.label? then layer.label else layer._category
        map[entry.x].push { label: label, y: entry.y, className: className }
    ({group: k, values: v} for k, v of map)

  # Draws the bar char.
  draw: ->
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

    super()
