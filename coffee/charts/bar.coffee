# Basic bar chart
#
# TODO Implement the style option
# 
# Options:
#   style: 'grouped' (default), 'stacked', or 'normal-stacked'
#
class F.Chart.Bar extends F.Chart.Plot
  defaults = 
    style: 'grouped'

  constructor: (@options={}) ->
    super(@options = F.Util.defaults(@options, defaults))

  x: ->
    d3.scale.ordinal()
      .domain(F.Util.domain(@data))
      .rangeRoundBands([0, @width-@margins.left-@margins.right], .1)

  x1: (x0) ->
    d3.scale.ordinal()
      .domain((layer.label for layer in @data))
      .rangeRoundBands([0, x0.rangeBand()], .08)

  y: ->
    extent = @extent((d) -> d.y)
    extent[0] = Math.min(0, extent[0])
    d3.scale.linear()
      .domain(extent)
      .range([@height - @margins.top - @margins.bottom, 0])

  _remapData: ->
    map = {}
    for layer in @data
      className = 'bar ' + layer.className.replace(/\s*layer\s*/, '')
      for entry in layer.values
        map[entry.x] ?= []
        map[entry.x].push { label: layer.label, y: entry.y, className: className }
    ({group: k, values: v} for k, v of map)

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

    rects.transition().duration(500)
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
      .duration(400)
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