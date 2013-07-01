
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


PIE_DATA = [
  { label: 'Alpha', value: 10 },
  { label: 'Beta', value: 20 },
  { label: 'Gamma', value: 40 },
  { label: 'Tau', value: 30 }
]


LAYER_DATA = [
  {
    label: 'Series A'
    data: [
      { x: 0, y: 0 },
      { x: 1, y: 100 },
      { x: 2, y: 400 },
      { x: 3, y: 900 },
      { x: 4, y: 1100 },
      { x: 5, y: 2500 }
    ]
  },
  {
    label: 'Series B'
    data: [
      { x: 0, y: 0 },
      { x: 1, y: 150 },
      { x: 2, y: 200 },
      { x: 3, y: 700 },
      { x: 4, y: 100 },
      { x: 5, y: 3400 }
    ]
  },
  {
    label: 'Series B'
    data: [
      { x: 0, y: 90 },
      { x: 1, y: 330 },
      { x: 2, y: 20 },
      { x: 3, y: 1230 },
      { x: 4, y: 140 },
      { x: 5, y: 900 }
    ]
  }
]



#
# Global Namespace
#

window.F ?= {}
window.F.Chart ?= {}
window.F.Util ?= {}
window.F.Formats ?= {}

#
# Constants
#
CATEGORY_COLORS = [
  "#d0743c",
  "#98abc5",
  "#6b486b",
  "#8a89a6",
  "#a05d56",
  "#ff8c00",
  "#7b6888"
]

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


# Creates "dasherized" class names from strings
F.Util.dasherize = (str) ->
  str.replace("\n", '').replace(/\s+/, '-').toLowerCase()


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



#
# TODO Better documentation
# Represents two dimensional plots with multiple data series
#
# Options:
#   colors - Categorical colors for the layer data
#   layers - Layers to render using the multi-plot
#
class F.Chart.MultiPlot extends F.Chart.Plot
  defaults =
    colors: CATEGORY_COLORS

  constructor: (@options={}) ->
    @layers = @options.layers or LAYER_DATA
    super(@options = F.Util.defaults(@options, defaults))
    @flatten()

  flatten: ->
    @data = []
    for layer in @layers
      for entry in layer.data
        @data.push { x: entry.x, y: entry.y, label: layer.label, className: F.Util.dasherize(layer.label) }
    @data

  update: (@data) ->
    @flatten()
    @draw()

  # Scales
  x: ->
    d3.scale.linear()
      .domain(d3.extent(@data, (d) -> d.x))
      .range([0, @width - @margins.right - @margins.left])

  y: ->
    d3.scale.linear()
      .domain(d3.extent(@data, (d) -> d.y))
      .range([@height - @margins.top - @margins.bottom, 0])

  # Colors
  color: ->
    d3.scale.ordinal().range(@options.colors)


# Basic single line chart
# Sub-types: Multi-series
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
# Sub-types: stacked, bivariate
class F.Chart.Area extends F.Chart.Line
  draw: ->
    area = d3.svg.area()
      .x((d) => (@x() d.x))
      .y1((d) => (@y() d.y))
      .y0(@height - @margins.bottom - @margins.top)

    @svg.append("path")
      .datum(@data)
      .attr("class", "area")
      .attr("d", area)

    super()
    

# Basic bar chart
# Sub-types: stacked, normalized stacked, grouped
class F.Chart.Bar extends F.Chart.Plot
  x: ->
    d3.scale.ordinal()
      .rangeRoundBands([0, @width-@margins.left-@margins.right], .1)
      .domain(@data.map((d) -> d.x))

  draw: ->
    [x, y] = [@x(), @y()]

    @svg.selectAll(".bar")
      .data(@data)
    .enter().append("rect")
      .attr("class", "bar")
      .attr("x", (d) -> x(d.x))
      .attr("width", x.rangeBand())
      .attr("y", (d) => y(d.y))
      .attr("height", (d) => @height - @margins.top - @margins.bottom - y(d.y))

    super()


# Scatter Plot
class F.Chart.Scatter extends F.Chart.MultiPlot
  defaults =
    radius: 3.5

  constructor: (@options={}) ->
    super(@options = F.Util.defaults(@options, defaults))

  draw: ->
    super()
    [x, y, color] = [@x(), @y(), @color()]
    @svg.selectAll(".dot")
      .data(@data)
    .enter().append("circle")
      .attr("class", (d) -> "dot #{d.className}")
      .attr("r", @options.radius)
      .attr("cx", (d) -> x(d.x))
      .attr("cy", (d) -> y(d.y))
      .style("fill", (d) -> color(d.label))

    




#
# Non-plot charts
#



# Basic Pie Chart  
class F.Chart.Pie extends F.Chart.Base
  defaults =
    margin: 10
    colors: CATEGORY_COLORS

  constructor: (@options={}) ->
    @options.data = PIE_DATA unless @options.data?
    super(@options = F.Util.defaults(@options, defaults))
    @svg = @svg.append('g')
      .attr("transform", "translate(#{@width/2}, #{@height/2})")

  arc: ->
    radius = Math.max(@width, @height) / 2
    d3.svg.arc().outerRadius(radius - @options.margin).innerRadius(0)

  pie: ->
    d3.layout.pie().sort(null).value (d) -> d.value

  color: ->
    d3.scale.ordinal().range(@options.colors)

  draw: ->
    [arc, pie, color] = [@arc(), @pie(), @color()]

    arcs = @svg.selectAll(".arc")
      .data(pie(@data))
    .enter().append("g")
      .attr("class", "arc pie");

    arcs.append("path")
      .attr("d", arc)
      .style("fill", (d) => color(d.data.label))

    arcs.append("text")
      .attr("transform", (d) -> "translate(#{arc.centroid(d)})")
      .attr("dy", ".35em")
      .style("text-anchor", "middle")
      .text((d) -> d.data.label);



# Basic Donut Chart
class F.Chart.Donut extends F.Chart.Pie
  defaults =
    margin: 10
    inner: 60

  constructor: (@options={}) ->
    super(@options = F.Util.defaults(@options, defaults))

  arc: ->
    radius = Math.max(@width, @height) / 2
    d3.svg.arc()
      .outerRadius(radius - @options.margin)
      .innerRadius(radius - @options.inner)







# Base Class for all charts and plots
#class Fastly.d3.Chart

# class Fastly.d3.Area extends Fastly.d3.Chart
#   

# class Fastly.d3.Bar extends Fastly.d3.Chart
#   

# class Fastly.d3.Scatter extends Fastly.d3.Chart

# class Fastly.d3.Pie extends Fastly.d3.Chart

# class Fastly.d3.Donut

