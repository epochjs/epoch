#
# Timeseries bar chart
#
class F.Time.Bar extends F.Chart.Base
  # Time Formatting
  timeFormat = d3.time.format('%I:%M:%S %p')
  format = (d) ->
    date = new Date(d*1000)
    timeFormat(date)  

  # Default Values
  defaults =
    dimensions:
      width: 900
      height: 150
    windowSize: 45
    spacing: 0.03
    ticks:
      top: 5
      bottom: 5
    tickFormats:
      top: format
      bottom: format
      left: F.Formats.si
      right: F.Formats.si

  constructor: (@options={}) ->
    super(@options = F.Util.defaults(@options, defaults))
    
    @window = []
    @labels = (d.label for d in @data)

    offsets = []
    for i in [0...@data.length]
      for k in [0...@data[i].values.length]
        entry = @data[i].values[k]
        unless i
          entry.y0 = 0
          offsets.push entry.y
        else
          entry.y0 = offsets[k]
          offsets[k] += entry.y

    console.log @data


  x: ->
    d3.scale.linear()
      .domain([0, 1])
      .range([0, @barWidth()])

  y: ->
    max = 0
    for i in [0...@data[0].values.length]
      sum = 0
      for layer in @data
        sum += layer.values[i].y
      max = sum if sum > max
    d3.scale.linear()
      .domain([0, max])
      .range([@height, 0])

  barWidth: ->
    (@width / (@options.windowSize))|0

  push: (entry, draw=true) ->
    @data[0].values.push entry
    len = @data[0].values.length
    if (len > @options.windowSize)
      @data[0].values = @data[0].values.slice(len - @options.windowSize)
    @draw() if draw

  draw: ->
    [x, y] = [@x(), @y()]
    w = @barWidth()
    h = @height

    data = @data[0].values

    # 1) Join
    bars = @svg.selectAll('.bar.with-line')
      .data(data, (d) -> d.time)

    # 2) Enter / Create
    bars.enter().append('rect')
      .attr('x', (d, i) -> x(i+1) - .5)
      .attr('width', w)
      .attr('y', (d) -> h - y(d.y))
      .attr('height', (d) -> y(d.y))
      .attr('class', 'category1 bar with-line')
      .transition()
        .duration(1000)
        .attr('x', (d, i) -> x(i) - .5)

    # 3) Update
    bars.transition()
      .duration(1000)
      .attr("x", (d, i) -> x(i) - .5)
      .attr('y', (d) -> h - y(d.y))
      .attr('height', (d) -> y(d.y))

    # 4) Exit / Remove
    bars.exit()
      .transition()
      .style('opacity', 0)
      .duration(400)
      .remove()

    
	
