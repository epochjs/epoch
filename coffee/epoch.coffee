#
# Global Namespace
# 

window.Epoch ?= {}
window.Epoch.Chart ?= {}
window.Epoch.Time ?= {}
window.Epoch.Util ?= {}
window.Epoch.Formats ?= {}

#
# Utility Functions
#

# Lil' helpers
Epoch.isArray = (v) -> $.type(v) == 'array'
Epoch.isObject = (v) -> $.type(v) == 'object'
Epoch.isString = (v) -> $.type(v) == 'string'
Epoch.isFunction = (v) -> $.type(v) == 'function'
Epoch.warn = (msg) -> (console.warn or console.log)("Warning: #{msg}")

# Exception handling
Epoch.exception = (msg) ->
  throw "Epoch Error: #{msg}"

# Shallow copy from an original source
Epoch.Util.copy = (original) ->
  return null unless original?
  copy = {}
  copy[k] = v for k, v of original
  return copy

# Deep defaults copy
Epoch.Util.defaults = (options, defaults) ->
  result = Epoch.Util.copy(options)
  for k, v of defaults
    if options[k]? and defaults[k]?
      if !Epoch.isArray(options[k]) and Epoch.isObject(options[k]) and Epoch.isObject(defaults[k])
        result[k] = Epoch.Util.defaults(options[k], defaults[k])
      else
        result[k] = options[k]
    else if options[k]?
      result[k] = options[k]
    else
      result[k] = defaults[k]
  return result

# Formats numbers with standard postfixes (e.g. K, M, G)
Epoch.Util.formatSI = (v, fixed=1, fix_integers=false) ->
  return v if v < 1000
  for i, label of ['K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y']
    base = Math.pow(10, ((i|0)+1)*3)
    if v >= base and v < Math.pow(10, ((i|0)+2)*3)
      q = v/base
      q = q.toFixed(fixed) unless (q|0) == q and !fix_integers
      return "#{q} #{label}" 


# Creates "dasherized" class names from strings
Epoch.Util.dasherize = (str) ->
  str.replace("\n", '').replace(/\s+/, '-').toLowerCase()

# Finds the full domain of a given variable from an array of layers
Epoch.Util.domain = (layers, key='x') ->
  set = {}
  for layer in layers
    set[entry[key]] = true for entry in layer.values
  (k for k, v of set)


#
# Tick Formatters
#



Epoch.Formats.regular = (d) -> d
Epoch.Formats.si = (d) -> Epoch.Util.formatSI(d)
Epoch.Formats.percent = (d) -> (d*100).toFixed(1) + "%"


d3Seconds = d3.time.format('%I:%M:%S %p')
Epoch.Formats.seconds = (t) -> d3Seconds(new Date(t*1000))

#
# Eventing
# 
class Epoch.Events
  constructor: ->
    @_events = {}

  on: (name, callback) ->
    return unless callback?
    @_events[name] ?= []
    @_events[name].push callback

  off: (name, callback) ->
    return unless Epoch.isObject(@_events[name])
    return delete(@_events[name]) unless callback?
    while (i = @_events[name].indexOf(callback)) >= 0
      @_events[name].splice(i, 1)

  trigger: (name) ->
    return unless Epoch.isObject(@_events[name])
    args = (arguments[i] for i in [1...arguments.length])
    for callback in @_events[name]
      fn = null
      if Epoch.isString(callback)
        fn = @[callback]
      else if Epoch.isFunction(callback)
        fn = callback
      unless fn?
        Epoch.exception "Callback for event '#{name}' is not a function or reference to a method."
      fn.apply @, args



#
# Common functionality for both SVG and Canvas charts.
#
class Epoch.Chart.Base extends Epoch.Events
  defaults =
    dimensions:
      width: 320
      height: 240

  constructor: (@options) ->
    super()

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
      classes.push(Epoch.Util.dasherize layer.label) if layer.label?
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
class Epoch.Chart.SVG extends Epoch.Chart.Base
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
class Epoch.Chart.Canvas extends Epoch.Chart.Base
  constructor: (@options={}) ->
    super(@options)
    @canvas = $("<canvas></canvas>")
    @canvas.attr('width', @width).attr('height', @height)
    @el.append(@canvas) if @el?
    @ctx = @canvas.get(0).getContext('2d')

  getStyles: (selector) ->
    CanvasCSS.getStyles(selector, @el)


# The Reference SVG for mapping css styles to canvas elements
class CanvasCSS
  @cache = {}
  @styleList = ['fill', 'stroke', 'stroke-width']
  @container = null

  @load: ->
    $('body').append('<div id="_canvas_css_reference"></div>')
    CanvasCSS.container = $('#_canvas_css_reference', 'body')

  @containerId: (container) ->
    "#{container.attr('id')}.#{container.attr('class')}"

  @getSVG: (container) ->
    id = CanvasCSS.containerId(container)
    el = CanvasCSS.svgElements[id]
    unless el?
      clone = $(container).clone().html('<svg></svg>')
      CanvasCSS.svgContainer.append(clone)
      el = CanvasCSS.svgElements[id] = $('svg', clone)
    return el

  @getStyles: (selector, container) ->
    # 0) Check for cached styles
    cacheKey = "#{CanvasCSS.containerId(container)}__#{selector}"
    cache = CanvasCSS.cache[cacheKey]
    return cache if cache?

    # 1) Create Reference SVG
    clone = $(container).clone().html('<svg></svg>')
    clone.removeAttr('style')
    CanvasCSS.container.append(clone)
    svg = $('svg', clone)
    
    # 2) Create Reference Element
    levels = selector.split(/\s+/)
    parent = root = put(levels.shift())
    while levels.length
      el = put(levels.shift())
      parent.appendChild el
      parent = el
    svg.html(root)
    ref = $(selector, svg)

    # 3) Collect & Cache Styles
    styles = {}
    for name in CanvasCSS.styleList
      styles[name] = ref.css(name)
    CanvasCSS.cache[cacheKey] = styles

    # 4) Cleanup and return the styles
    $(clone, CanvasCSS.container).remove()
    return styles

$ CanvasCSS.load


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
class Epoch.Chart.Plot extends Epoch.Chart.SVG
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
      top: Epoch.Formats.regular
      bottom: Epoch.Formats.regular
      left: Epoch.Formats.si
      right: Epoch.Formats.si

  constructor: (@options={}) ->
    givenMargins = Epoch.Util.copy(@options.margins) or {}
    super(@options = Epoch.Util.defaults(@options, defaults))

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