
# TODO Document Me
# TODO Style Guidelines
# TODO custom additional classes on elements (e.g. path.requests, etc.)
# TODO Document data formats
# TODO Legends

window.TEST_DATA = [
  {
    label: 'Layer 1'
    values: [
      { x: 0, y: 0 },
      { x: 1, y: 100 },
      { x: 2, y: 400 },
      { x: 3, y: 900 },
      { x: 4, y: 1100 },
      { x: 5, y: 2500 }
    ]
  },
  {
    label: 'Layer 2'
    values: [
      { x: 0, y: 340 },
      { x: 1, y: 10 },
      { x: 2, y: 1400 },
      { x: 3, y: 80 },
      { x: 4, y: 100 },
      { x: 5, y: 20 }
    ]
  },
  {
    label: 'Layer 3'
    values: [
      { x: 0, y: 940 },
      { x: 1, y: 1233 },
      { x: 2, y: 200 },
      { x: 3, y: 1976 },
      { x: 4, y: 1560 },
      { x: 5, y: 800 }
    ]
  }
]

window.TEST_DATA_2 = [
  {
    label: 'Layer 1'
    values: [
      { x: 0, y: 1200 },
      { x: 1, y: 0 },
      { x: 2, y: 300 },
      { x: 3, y: 170 },
      { x: 4, y: 1220 },
      { x: 5, y: 40 },
      { x: 6, y: 230}
    ]
  },
  {
    label: 'Layer 2'
    values: [
      { x: 0, y: 3400 },
      { x: 1, y: 523 },
      { x: 2, y: 190 },
      { x: 3, y: 803 },
      { x: 4, y: 1030 },
      { x: 5, y: 2042 },
      { x: 6, y: 820}
    ]
  }
]

window.TEST_DATA_3 = [
  {
    label: 'Layer 1'
    values: [
      { x: 0, y: 100 },
      { x: 1, y: 200 },
      { x: 2, y: 300 },
      { x: 3, y: 400 },
      { x: 4, y: 500 },
      { x: 5, y: 600 }
    ]
  },
  {
    label: 'Layer 2'
    values: [
      { x: 0, y: 600 },
      { x: 1, y: 500 },
      { x: 2, y: 400 },
      { x: 3, y: 300 },
      { x: 4, y: 200 },
      { x: 5, y: 100 }
    ]
  }
]

window.BAR_DATA = [
  {
    label: 'Alpha'
    values: [
      { x: 'A', y: 30 },
      { x: 'B', y: 10 },
      { x: 'C', y: 12 },
      { x: 'D', y: 32 },
      { x: 'E', y: 11 },
      { x: 'F', y: 25 }
    ]
  },
  {
    label: 'Beta'
    values: [
      { x: 'A', y: 34 },
      { x: 'B', y: 18 },
      { x: 'C', y: 14 },
      { x: 'D', y: 30 },
      { x: 'E', y: 19 },
      { x: 'F', y: 20 }
    ]
  },
  {
    label: 'Gamma'
    values: [
      { x: 'A', y: 13 },
      { x: 'B', y: 12 },
      { x: 'C', y: 20 },
      { x: 'D', y: 19 },
      { x: 'E', y: 15 },
      { x: 'F', y: 22 }
    ]
  }
]

window.BAR_DATA_2 = [
  {
    label: 'Alpha'
    values: [
      { x: 'A', y: 10 },
      { x: 'B', y: 19 },
      { x: 'C', y: 22 },
      { x: 'D', y: 18 },
      { x: 'E', y: 5 },
      { x: 'F', y: 16 },
      { x: 'G', y: 7 }
    ]
  },
  {
    label: 'Beta'
    values: [
      { x: 'A', y: 4 },
      { x: 'B', y: 10 },
      { x: 'C', y: 19 },
      { x: 'D', y: 33 },
      { x: 'E', y: 7 },
      { x: 'F', y: 16 },
      { x: 'G', y: 14 }
    ]
  }
]

window.BAR_DATA_SINGLE = [
  {
    label: 'Alpha'
    values: [
      { x: 'A', y: 30 },
      { x: 'B', y: 10 },
      { x: 'C', y: 12 },
      { x: 'D', y: 32 },
      { x: 'E', y: 11 },
      { x: 'F', y: 25 }
    ]
  }
]

window.BAR_DATA_SINGLE_2 = [
  {
    label: 'Alpha'
    values: [
      { x: 'A', y: 10 },
      { x: 'B', y: 40 },
      { x: 'C', y: 42 },
      { x: 'D', y: 12 },
      { x: 'E', y: 5 },
      { x: 'F', y: 17 }
    ]
  }
]

window.PIE_DATA = [
  { label: 'Alpha', value: 10 },
  { label: 'Beta', value: 20 },
  { label: 'Gamma', value: 40 },
  { label: 'Tau', value: 30 }
]

window.PIE_DATA_2 = [
  { label: 'Alpha', value: 15 },
  { label: 'Beta', value: 35 },
  { label: 'Gamma', value: 27 },
  { label: 'Tau', value: 23 }
]

CATEGORIES = ['Series A', 'Series B', 'Series C']
window.SCATTER_DATA = []
window.SCATTER_DATA_2 = []

for name in CATEGORIES
  SCATTER_DATA.push(layer = { label: name, values: [] })
  SCATTER_DATA_2.push(layer2 = { label: name, values: [] })
  for i in [1..20]
    layer.values.push { x: Math.random() * 1000, y: Math.random() * 1000 }
    layer2.values.push { x: Math.random() * 1000, y: Math.random() * 1000 }



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

# Lil' helpers

F.isArray = (v) -> $.type(v) == 'array'
F.isObject = (v) -> $.type(v) == 'object'
F.warn = (msg) -> (console.warn or console.log)("Warning: #{msg}")

# Shallow copy from an original source
F.Util.copy = (original) ->
  return null unless original?
  copy = {}
  copy[k] = v for k, v of original
  return copy

# Deep defaults copy
F.Util.defaults = (options, defaults) ->
  result = F.Util.copy(options)
  for k, v of defaults
    if options[k]? and defaults[k]?
      if !F.isArray(options[k]) and F.isObject(options[k]) and F.isObject(defaults[k])
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

# Finds the full domain of a given variable from an array of layers
F.Util.domain = (layers, key='x') ->
  set = {}
  for layer in layers
    set[entry[key]] = true for entry in layer.values
  (k for k, v of set)


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
    # TODO Remove Test data for release
    @update(@options.data or TEST_DATA, false)

    # Eventing
    @_events = {}

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

  update: (data, draw=true) ->
    category = 1
    for layer in data
      classes = ['layer']
      classes.push "category#{category}"
      classes.push(F.Util.dasherize layer.label) if layer.label?
      layer.className = classes.join(' ')
      category++
    @data = data
    @draw() if draw

  extent: (cmp) ->
    [
      d3.min(@data, (layer) -> d3.min(layer.values, cmp)),
      d3.max(@data, (layer) -> d3.max(layer.values, cmp))
    ]

  on: (name, callback) ->
    return unless callback?
    @_events[name] ?= []
    @_events[name].push callback

  off: (name, callback) ->
    return unless F.isObject(@_events[name])
    return delete(@_events[name]) unless callback?
    while (i = @_events[name].indexOf(callback)) >= 0
      @_events[name].splice(i, 1)

  trigger: (name) ->
    return unless F.isObject(@_events[name])
    args = (arguments[i] for i in [1...arguments.length])
    for fn in @_events[name]
      fn.apply @, args

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
      .domain(@extent((d) -> d.x))
      .range([0, @width - @margins.right - @margins.left])

  y: ->
    d3.scale.linear()
      .domain(@extent((d) -> d.y))
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
    if @_axesDrawn
      @redrawAxes()
    else
      @drawAxes()

  redrawAxes: ->
    if @hasAxis('bottom')
      @svg.selectAll('.x.axis.bottom').transition()
        .duration(500)
        .ease('linear')
        .call(@bottomAxis())
    if @hasAxis('top')
      @svg.selectAll('.x.axis.top').transition()
        .duration(500)
        .ease('linear')
        .call(@topAxis())
    if @hasAxis('left')
      @svg.selectAll('.y.axis.left').transition()
        .duration(500)
        .ease('linear')
        .call(@leftAxis())
    if @hasAxis('right')
      @svg.selectAll('.y.axis.right').transition()
        .duration(500)
        .ease('linear')
        .call(@rightAxis())

  drawAxes: ->
    if @hasAxis('bottom')
      @svg.append("g")
        .attr("class", "x axis bottom")
        .attr("transform", "translate(0, #{@height-@margins.top-@margins.bottom})")
        .call(@bottomAxis())
    if @hasAxis('top')
      @svg.append("g")
        .attr('class', 'x axis top')
        .call(@topAxis())
    if @hasAxis('left')
      @svg.append("g")
        .attr("class", "y axis left")
        .call(@leftAxis())
    if @hasAxis('right')
      @svg.append('g')
        .attr('class', 'y axis right')
        .attr('transform', "translate(#{@width-@margins.left-@margins.right}, 0)")
        .call(@rightAxis())
    @_axesDrawn = true


# Line Chart
class F.Chart.Line extends F.Chart.Plot
  line: ->
    [x, y] = [@x(), @y()]
    d3.svg.line().x((d) => (x d.x)).y((d) => (y d.y))

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
    data: BAR_DATA

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


# Area Chart
class F.Chart.Area extends F.Chart.Plot
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


class F.Chart.Scatter extends F.Chart.Plot
  defaults =
    radius: 3.5
    data: SCATTER_DATA

  constructor: (@options={}) ->
    console.log defaults.data
    super(@options = F.Util.defaults(@options, defaults))

  draw: ->
    super()

    [x, y] = [@x(), @y()]

    layer = @svg.selectAll('.layer')
      .data(@data, (d) -> d.label)

    layer.enter().append('g')
      .attr('class', (d) -> d.className)

    dots = layer.selectAll('.dot')
      .data((l) -> l.values)

    dots.transition().duration(500)
      .attr("cx", (d) -> x(d.x))
      .attr("cy", (d) -> y(d.y))

    dots.enter().append('circle')
      .attr('class', 'dot')
      .attr("r", @options.radius)
      .attr("cx", (d) -> x(d.x))
      .attr("cy", (d) -> y(d.y))
    
    dots.exit().transition()
      .duration(750)
      .style('opacity', 0)
      .remove()

    layer.exit().transition()
      .duration(750)
      .style('opacity', 0)
      .remove()


# Basic Pie Chart  
class F.Chart.Pie extends F.Chart.Base
  defaults =
    margin: 10
    inner: 0
    data: PIE_DATA

  constructor: (@options={}) ->
    super(@options = F.Util.defaults(@options, defaults))
    radius = Math.max(@width, @height) / 2
    @pie = d3.layout.pie().sort(null)
      .value (d) -> d.value
    @arc = d3.svg.arc()
      .outerRadius(radius - @options.margin)
      .innerRadius(@options.inner)
    @svg = @svg.append('g')
      .attr("transform", "translate(#{@width/2}, #{@height/2})")

  draw: ->
    arcs = @svg.selectAll(".arc")
      .data(@pie(@data), (d) -> d.data.label)

    arcs.enter().append('g')
      .attr('class', (d) -> "arc pie " + d.data.className)

    arcs.select('path')
      .attr('d', @arc)

    arcs.select('text')
      .attr("transform", (d) => "translate(#{@arc.centroid(d)})")
      .text((d) -> d.data.label)

    path = arcs.append("path")
      .attr("d", @arc)
      .each((d) -> @._current = d)

    text = arcs.append("text")
      .attr("transform", (d) => "translate(#{@arc.centroid(d)})")
      .attr("dy", ".35em")
      .style("text-anchor", "middle")
      .text((d) -> d.data.label)

    arcs.exit().remove()

# "I think, baby, I was born just a little late!" -- Middle Class Rut