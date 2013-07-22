# Area Chart
class Epoch.Chart.Area extends Epoch.Chart.Plot
  y: ->
    a = []
    for layer in @data
      for k, v of layer.values
        a[k] += v.y if a[k]?
        a[k] = v.y unless a[k]?
    d3.scale.linear()
      .domain([0, d3.max(a)])
      .range([@height - @margins.top - @margins.bottom, 0])

  draw: ->
    [x, y] = [@x(), @y()]

    area = d3.svg.area()
      .x((d) -> x(d.x))
      .y0((d) -> y(d.y0))
      .y1((d) -> y(d.y0 + d.y))

    stack = d3.layout.stack()
      .values((d) -> d.values)

    data = stack(@data)

    # 1) Join
    layer = @svg.selectAll('.layer')
      .data(@data, (d) -> d.label)

    # 2) Update
    layer.select('.area').transition().duration(500)
      .attr('d', (d) -> area(d.values))

    # 3) Enter / Create
    layer.enter().append('g')
      .attr('class', (d) -> d.className)

    layer.append('path')
      .attr('class', 'area')
      .attr('d', (d) -> area(d.values))

    # 4) Update new & existing

    # 5) Exit / Remove
    layer.exit().transition()
      .duration(750)
      .style('opacity', 0)
      .remove()

    super()   