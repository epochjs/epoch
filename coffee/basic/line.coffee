# Static line chart implementation (using d3).
class Epoch.Chart.Line extends Epoch.Chart.Plot

  # @return [Function] The line generator used to construct the plot.
  line: ->
    [x, y] = [@x(), @y()]
    d3.svg.line().x((d) => (x d.x)).y((d) => (y d.y))

  # Draws the line chart.
  draw: ->
    [x, y, line] = [@x(), @y(), @line()]

    # 1) Join
    layer = @svg.selectAll('.layer')
      .data(@data, (d) -> d.label)

    # 2) Update (only existing)
    layer.select('.line').transition().duration(500)
      .attr('d', (l) -> line(l.values))      

    # 3) Enter (Create)
    layer.enter().append('g')
      .attr('class', (l) -> l.className)
      .append('path')
        .attr('class', 'line')
        .attr('d', (l) -> line(l.values))

    # 4) Update (existing & new)
    # Nuuupp

    # 5) Exit (Remove)
    layer.exit().transition().duration(750)
      .style('opacity', '0')
      .remove()  

    super()