#
# Global Namespace
# 

window.F ?= {}
window.F.Chart ?= {}
window.F.Time ?= {}
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


d3Seconds = d3.time.format('%I:%M:%S %p')
F.Formats.seconds = (t) -> d3Seconds(new Date(t*1000))

#
# Eventing
# 
class F.Events
  constructor: ->
    @_events = {}

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
    fn.apply(@, args) for fn in @_events[name]



#
# Common functionality for both SVG and Canvas charts.
#
class F.Chart.Base extends F.Events
  defaults =
    dimensions:
      width: 320
      height: 240

  constructor: (@options) ->
    @setData(@options.data or [])

    @el = $(@options.el) if @options.el?

    @width = @options.width
    @height = @options.height

    if @el?
      @width = $(@el).width() unless @width?
      @height = $(@el).height() unless @height?
    else
      @width = defaults.dimensions.width unless @width?
      @height = defaults.dimensions.height unless @height?

  setData: (data) ->
    category = 1
    for layer in data
      classes = ['layer']
      classes.push "category#{category}"
      classes.push(F.Util.dasherize layer.label) if layer.label?
      layer.className = classes.join(' ')
      category++
    @data = data

  update: (data, draw=true) ->
    @setData data
    @draw() if draw

  draw: -> # Abstract, must override in child classes

  extent: (cmp) ->
    [
      d3.min(@data, (layer) -> d3.min(layer.values, cmp)),
      d3.max(@data, (layer) -> d3.max(layer.values, cmp))
    ]
      

#
# Base class for all SVG charts (via d3)
#
# Options:
#
#   el - Where the svg belongs
#   data - Initial data for the chart
#   width - explicit chart width
#   height - explicit chart height
#   
class F.Chart.SVG extends F.Chart.Base
  constructor: (@options={}) ->
    super(@options)
    if @el?
      @svg = d3.select(@el.get(0)).append('svg')
    else
      @svg = d3.select(document.createElement('svg'))
    @svg.attr('width', @width).attr('height', @height)



#
# Base Class for all Canvas Based Charts 
#
class F.Chart.Canvas extends F.Chart.Base
  constructor: (@options={}) ->
    super(@options)
    @canvas = $("<canvas></canvas>")
    @canvas.attr('width', @width).attr('height', @height)
    @el.append(@canvas) if @el?
    @ctx = @canvas.get(0).getContext('2d')

  getStyles: (selector) ->
    return styles if (styles = canvasCSS.styles[selector])?
    ref = $(selector, canvasCSS.ref)

    # Construct & insert a reference element if none exists
    unless ref.size() > 0
      levels = selector.split(/\s+/)
      parent = root = put(levels.shift())
      while levels.length
        el = put(levels.shift())
        parent.appendChild el
        parent = el
      canvasCSS.ref.append(root)
      ref = $(selector, canvasCSS.ref)

    # Fetch and stash yonder styles from the reference
    styles = {}
    for name in ['fill', 'stroke', 'stroke-width']
      styles[name] = ref.css(name)
    canvasCSS.styles[selector] = styles


# The Reference SVG for mapping css styles to canvas elements
canvasCSS =
  ref: $('<svg id="_canvas_reference"></svg>')
  styles: {}
  load: -> $('body').append(canvasCSS.ref)
$ canvasCSS.load




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
class F.Chart.Plot extends F.Chart.SVG
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

  innerWidth: ->
    @width - (@margins.left + @margins.right)

  innerHeight: ->
    @height - (@margins.top + @margins.bottom)

  # Scales
  x: ->
    d3.scale.linear()
      .domain(@extent((d) -> d.x))
      .range([0, @innerWidth()])

  y: ->
    d3.scale.linear()
      .domain(@extent((d) -> d.y))
      .range([@innerHeight(), 0])

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
        .attr("transform", "translate(0, #{@innerHeight()})")
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
        .attr('transform', "translate(#{@innerWidth()}, 0)")
        .call(@rightAxis())
    @_axesDrawn = true

# "I think, baby, I was born just a little late!" -- Middle Class Rut