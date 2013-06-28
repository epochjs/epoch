#
# TODO - Document Me
#

TEST_DATA = [
  { x: 0, y: 0 },
  { x: 1, y: 100 },
  { x: 2, y: 400 },
  { x: 3, y: 900 },
  { x: 4, y: 1600 },
  { x: 5, y: 2500 }
]

# Global Namespace
window.F ?= {}
window.F.Chart ?= {}


#
# Formats large numbers using standard postfixes
#
F.format_si = (v, fixed=1, fix_integers=false) ->
  return v if v < 1000
  for i, label of ['K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y']
    base = Math.pow(10, ((i|0)+1)*3)
    if v >= base and v < Math.pow(10, ((i|0)+2)*3)
      q = v/base
      q = q.toFixed(fixed) unless (q|0) == q and !fix_integers
      return "#{q} #{label}" 


#
# Options:
#
#   el - Where the svg belongs
#   data - Initial data for the chart
#   width - explicit chart width
#   height - explicit chart height
#   
class F.Chart.Base
  defaults =
    dimensions: { width: 320, height: 240 }

  constructor: (@options={}) ->
    # Initialize data
    if @options.data?
      @data = @options.data
    else
      @data = TEST_DATA

    # Handle svg placement / creation
    if @options.el?
      @el = $(@options.el)
      @svg = d3.select(@options.el).append('svg')
    else
      @svg = d3.select(document.createElement('svg'))

    # Width and height
    @width = @options.width
    @height = @options.height

    if @el?
      @width = $(@el).width() unless @width?
      @height = $(@el).height() unless @height?
    else
      @width = defaults.dimensions.width unless @width?
      @height = defaults.dimensions.height unless @height?

    @svg.attr('width', @width).attr('height', @height)

  update: (@data) ->
    @draw()

  draw: -> # Abstract, must override in child classes


#
# Options:
#   margins - chart margins
#   axes - list of axes to display (top, bottom, left, right)
#
class F.Chart.Line extends F.Chart.Base
  # Sub-types: multi-series

  defaults =
    margins: {top: 25, right: 50, bottom: 25, left: 50}
    axes: ['left', 'bottom']

  constructor: (@options={}) ->
    super(@options)

    # Margins and axes
    @options.axes ?= defaults.axes
    @options.margins ?= {}
    @margins = { top: 10, left: 0, bottom: 10, right: 0 }

    for pos in ['top', 'right', 'bottom', 'left']
      if @options.margins[pos]?
        @margins[pos] = @options.margins[pos]
      else if @hasAxis(pos)
        @margins[pos] = defaults.margins[pos]
      
    # Nab the reference ot the svg element
    @svg = @svg.append("g")
      .attr("transform", "translate(#{@margins.left}, #{@margins.top})")

  hasAxis: (name) ->
    @options.axes.indexOf(name) > -1

  x: ->
    d3.scale.linear()
      .domain(d3.extent(@data, (d) -> d.x))
      .range([0, @width-@margins.right - @margins.left])

  y: ->
    d3.scale.linear()
      .domain(d3.extent(@data, (d) -> d.y))
      .range([@height - @margins.top - @margins.bottom, 0])

  draw: ->
    [x, y] = [@x(), @y()]

    line = d3.svg.line()
      .x((d) -> x(d.x))
      .y((d) -> y(d.y))
    
    @svg.append("path")
      .datum(@data)
      .attr("class", "line")
      .attr("d", line)

    @drawTopAxis() if @hasAxis('top')
    @drawRightAxis() if @hasAxis('right')
    @drawBottomAxis() if @hasAxis('bottom')
    @drawLeftAxis() if @hasAxis('left')

  drawTopAxis: ->
    @svg.append("g")
      .attr('class', 'x axis top')
      .call(d3.svg.axis().scale(@x()).orient('top'))

  drawRightAxis: ->
    yAxisRight = d3.svg.axis().scale(@y()).orient('right')
      .tickFormat( (d) -> F.format_si(d) )
    @svg.append('g')
      .attr('class', 'y axis right')
      .attr('transform', "translate(#{@width-@margins.left-@margins.right}, 0)")
      .call(yAxisRight)

  drawBottomAxis: ->
    @svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0, #{@height-@margins.top-@margins.bottom})")
        .call(d3.svg.axis().scale(@x()).orient('bottom'))

  drawLeftAxis: ->
    yAxis = d3.svg.axis().scale(@y()).orient('left')
      .tickFormat( (d) -> F.format_si(d) )
    @svg.append("g")
      .attr("class", "y axis")
      .call(yAxis)

      







# Base Class for all charts and plots
#class Fastly.d3.Chart


# class Fastly.d3.Area extends Fastly.d3.Chart
#   # Sub-types: stacked, bivariate

# class Fastly.d3.Bar extends Fastly.d3.Chart
#   # Sub-types: stacked, normalized stacked, grouped

# class Fastly.d3.Scatter extends Fastly.d3.Chart

# class Fastly.d3.Pie extends Fastly.d3.Chart

# class Fastly.d3.Donut

