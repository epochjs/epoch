
# TODO - Document Me
# TODO Style Guidelines
# TODO custom additional classes on elements (e.g. path.requests, etc.)


TEST_DATA = [
  { x: 0, y: 0 },
  { x: 1, y: 100 },
  { x: 2, y: 400 },
  { x: 3, y: 900 },
  { x: 4, y: 1100 },
  { x: 5, y: 2500 }
]

#
# Global Namespace
#

window.F ?= {}
window.F.Chart ?= {}
window.F.Util ?= {}
window.F.Formats ?= {}


#
# Utility Functions
#

# Shallow copy from an original source
F.Util.copy = (original) ->
  return null unless original?
  copy = {}
  copy[k] = v for k, v of original
  return copy

# Deep defaults copy (recursive)
F.Util.defaults = (options, defaults) ->
  result = F.Util.copy(options)

  # Helpers
  isArray = Array.isArray or (v) -> Object::toString.call(v) == '[object Array]'
  isObject = (v) -> v == Object(v)

  for k, v of defaults
    if options[k]? and defaults[k]?
      if !isArray(options[k]) and isObject(options[k]) and isObject(defaults[k])
        result[k] = F.Util.defaults(options[k], defaults[k])
      else
        result[k] = options[k]
    else if options[k]?
      result[k] = options[k]
    else
      result[k] = defaults[k]

  return result

# Formats numbers with standard postfixes (e.g. K, M, G)
F.Util.formatSI = (v, fixed=1, fix_integers=false) ->
  return v if v < 1000
  for i, label of ['K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y']
    base = Math.pow(10, ((i|0)+1)*3)
    if v >= base and v < Math.pow(10, ((i|0)+2)*3)
      q = v/base
      q = q.toFixed(fixed) unless (q|0) == q and !fix_integers
      return "#{q} #{label}" 

#
# Tick Formatters
#

F.Formats.regular = (d) -> d
F.Formats.si = (d) -> F.Util.formatSI(d)



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
# TODO Better Documentation
#
# Represents 2D plots (line, area, bar, scatter, etc.)
# Primarily this class handles axes and margins for subclasses such
# as the line plot, etc. Anything that is common to basic 2 dimensional
# plots can be found here.
#
# Options:
#   margins - chart margins
#   axes - list of axes to display (top, bottom, left, right)
#   ticks - Ticks to send along for each axis (top, bottom, left, right)
#   tickFormats - maps axes to tick formats (top, bottom, left, right)
#
class F.Chart.Plot extends F.Chart.Base
  defaults =
    margins:
      top: 25
      right: 50
      bottom: 25
      left: 50
    axes: ['left', 'bottom']
    ticks:
      top: 14
      bottom: 14
      left: 5
      right: 5
    tickFormats:
      top: F.Formats.regular
      bottom: F.Formats.regular
      left: F.Formats.si
      right: F.Formats.si

  constructor: (@options={}) ->
    givenMargins = F.Util.copy(@options.margins) or {}
    super(@options = F.Util.defaults(@options, defaults))

    # Margins are used in a special way and only for making room for axes.
    # However, a user may explicitly set margins in the options, so we need
    # to determine if they did so, and zero out the ones they didn't if no
    # axis is present.
    @margins = {}
    for pos in ['top', 'right', 'bottom', 'left']
      @margins[pos] = @options.margins[pos]
      @margins[pos] = 6 unless givenMargins[pos]? or @hasAxis(pos)
    
    # Add a translation for the top and left margins
    @svg = @svg.append("g")
      .attr("transform", "translate(#{@margins.left}, #{@margins.top})")

  # Basic accessors / mutators
  setTickFormat: (position, fn) ->
    @options.tickFormats[position] = fn

  hasAxis: (name) ->
    @options.axes.indexOf(name) > -1

  # Scales
  x: ->
    d3.scale.linear()
      .domain(d3.extent(@data, (d) -> d.x))
      .range([0, @width - @margins.right - @margins.left])

  y: ->
    d3.scale.linear()
      .domain(d3.extent(@data, (d) -> d.y))
      .range([@height - @margins.top - @margins.bottom, 0])

  # Axes creation
  bottomAxis: ->
    d3.svg.axis().scale(@x()).orient('bottom')
      .ticks(@options.ticks.bottom)
      .tickFormat(@options.tickFormats.bottom)

  topAxis: ->
    d3.svg.axis().scale(@x()).orient('top')
      .ticks(@options.ticks.top)
      .tickFormat(@options.tickFormats.top)

  leftAxis: ->
    d3.svg.axis().scale(@y()).orient('left')
      .ticks(@options.ticks.left)
      .tickFormat(@options.tickFormats.left)

  rightAxis: ->
    d3.svg.axis().scale(@y()).orient('right')
      .ticks(@options.ticks.right)
      .tickFormat(@options.tickFormats.right)

  # Drawing
  draw: ->
    super()
    @drawAxes()

  drawAxes: ->
    if @hasAxis('bottom')
      @svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0, #{@height-@margins.top-@margins.bottom})")
        .call(@bottomAxis())

    if @hasAxis('top')
      @svg.append("g")
        .attr('class', 'x axis top')
        .call(@topAxis())
    
    if @hasAxis('left')
      @svg.append("g")
        .attr("class", "y axis")
        .call(@leftAxis())

    if @hasAxis('right')
      @svg.append('g')
        .attr('class', 'y axis right')
        .attr('transform', "translate(#{@width-@margins.left-@margins.right}, 0)")
        .call(@rightAxis())


# Basic single line chart
class F.Chart.Line extends F.Chart.Plot
  draw: ->
    line = d3.svg.line()
      .x((d) => (@x() d.x))
      .y((d) => (@y() d.y))

    @svg.append("path")
      .datum(@data)
      .attr("class", "line")
      .attr("d", line)

    super()


# Basic single area chart
class F.Chart.Area extends F.Chart.Plot
  draw: ->
    area = d3.svg.area()
      .x((d) => (@x() d.x))
      .y1((d) => (@y() d.y))
      .y0(@height - @margins.bottom - @margins.top)

    @svg.append("path")
      .datum(@data)
      .attr("class", "area line")
      .attr("d", area)

    super()
    

  

  

  

      







# Base Class for all charts and plots
#class Fastly.d3.Chart


# class Fastly.d3.Area extends Fastly.d3.Chart
#   # Sub-types: stacked, bivariate

# class Fastly.d3.Bar extends Fastly.d3.Chart
#   # Sub-types: stacked, normalized stacked, grouped

# class Fastly.d3.Scatter extends Fastly.d3.Chart

# class Fastly.d3.Pie extends Fastly.d3.Chart

# class Fastly.d3.Donut

