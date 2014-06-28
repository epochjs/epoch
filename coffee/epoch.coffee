window.Epoch ?= {}
window.Epoch.Chart ?= {}
window.Epoch.Time ?= {}
window.Epoch.Util ?= {}
window.Epoch.Formats ?= {}

typeFunction = (objectName) -> (v) ->
  Object::toString.call(v) == "[object #{objectName}]"

# @return [Boolean] <code>true</code> if the given value is an array, <code>false</code> otherwise.
# @param v Value to test.
Epoch.isArray = Array.isArray or typeFunction('Array')

# @return [Boolean] <code>true</code> if the given value is an object, <code>false</code> otherwise.
# @param v Value to test.
Epoch.isObject = typeFunction('Object')

# @return [Boolean] <code>true</code> if the given value is a string, <code>false</code> otherwise.
# @param v Value to test.
Epoch.isString = typeFunction('String')

# @return [Boolean] <code>true</code> if the given value is a function, <code>false</code> otherwise.
# @param v Value to test.
Epoch.isFunction = typeFunction('Function')

# @return [Boolean] <code>true</code> if the given value is a number, <code>false</code> otherwise.
# @param v Value to test.
Epoch.isNumber = typeFunction('Number')

# Attempts to determine if a given value represents a DOM element. The result is always correct if the
# browser implements DOM Level 2, but one can fool it on certain versions of IE. Adapted from:
# <a href="http://goo.gl/yaD9hV">Stack Overflow #384286</a>.
# @return [Boolean] <code>true</code> if the given value is a DOM element, <code>false</code> otherwise.
# @param v Value to test.
Epoch.isElement = (v) ->
  if HTMLElement?
    v instanceof HTMLElement
  else
    v? and Epoch.isObject(v) and v.nodeType == 1 and Epoch.isString(v.nodeName)

# Sends a warning to the developer console with the given message.
# @param [String] msg Message for the warning.
Epoch.warn = (msg) ->
  (console.warn or console.log)("Epoch Warning: #{msg}")

# Raises an exception with the given message (with the 'Epoch Error:' preamble).
# @param [String] msg Specific message for the exception.
Epoch.exception = (msg) ->
  throw "Epoch Error: #{msg}"

# Generates shallow copy of an object.
# @return A shallow copy of the given object.
# @param [Object] original Object for which to make the shallow copy.
Epoch.Util.copy = (original) ->
  return null unless original?
  copy = {}
  copy[k] = v for k, v of original
  return copy

# Creates a deep copy of the given options filling in missing defaults.
# @param [Object] options Options to copy.
# @param [Object] defaults Default values for the options.
Epoch.Util.defaults = (options, defaults) ->
  result = Epoch.Util.copy(options)
  for k, v of defaults
    opt = options[k]
    def = defaults[k]
    bothAreObjects = Epoch.isObject(opt) and Epoch.isObject(def)

    if opt? and def?
      if bothAreObjects and not Epoch.isArray(opt)
        result[k] = Epoch.Util.defaults(opt, def)
      else
        result[k] = opt
    else if opt?
      result[k] = opt
    else
      result[k] = def

  return result

# Formats numbers with standard postfixes (e.g. K, M, G)
# @param [Number] v Value to format.
# @param [Integer] fixed Number of floating point digits to fix after conversion.
# @param [Boolean] fixIntegers Whether or not to add floating point digits to non-floating point results.
# @example Formatting a very large number
#   Epoch.Util.formatSI(1120000) == "1.1 M"
Epoch.Util.formatSI = (v, fixed=1, fixIntegers=false) ->
  if v < 1000
    q = v
    q = q.toFixed(fixed) unless (q|0) == q and !fixIntegers
    return q

  for i, label of ['K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y']
    base = Math.pow(10, ((i|0)+1)*3)
    if v >= base and v < Math.pow(10, ((i|0)+2)*3)
      q = v/base
      q = q.toFixed(fixed) unless (q|0) == q and !fixIntegers
      return "#{q} #{label}"

# Formats large bandwidth and disk space usage numbers with byte postfixes (e.g. KB, MB, GB, etc.)
# @param [Number] v Value to format.
# @param [Integer] fixed Number of floating point digits to fix after conversion.
# @param [Boolean] fixIntegers Whether or not to add floating point digits to non-floating point results.
# @example Formatting a large number of bytes
#   Epoch.Util.formatBytes(5.21 * Math.pow(2, 20)) == "5.2 MB"
Epoch.Util.formatBytes = (v, fixed=1, fix_integers=false) ->
  return "#{v} B" if v < 1024
  for i, label of ['KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB']
    base = Math.pow(1024, (i|0)+1)
    if v >= base and v < Math.pow(1024, (i|0)+2)
      q = v/base
      q = q.toFixed(fixed) unless (q|0) == q and !fix_integers
      return "#{q} #{label}"

# @return a "dasherized" css class names from a given string
# @example Using dasherize
#   Epoch.Util.dasherize('My Awesome Name') == 'my-awesome-name'
Epoch.Util.dasherize = (str) ->
  str.replace("\n", '').replace(/\s+/, '-').toLowerCase()

# @return the full domain of a given variable from an array of layers
# @param [Array] layers Layered plot data.
# @param [String] key The key name of the value at on each entry in the layers.
Epoch.Util.domain = (layers, key='x') ->
  set = {}
  domain = []
  for layer in layers
    for entry in layer.values
      continue if set[entry[key]]?
      domain.push(entry[key])
      set[entry[key]] = true 
  return domain

# Strips whitespace from the beginning and end of a string.
# @param [String] string String to trim.
# @return [String] The string without leading or trailing whitespace.
#   Returns null if the given parameter was not a string.
Epoch.Util.trim = (string) ->
  return null unless Epoch.isString(string)
  string.replace(/^\s+/g, '').replace(/\s+$/g, '')

# Converts a CSS color string into an RGBA string with the given opacity
# @param [String] color Color string to convert into an rgba
# @param [Number] opacity Opacity to use for the resulting color.
# @return the resulting rgba color string.
Epoch.toRGBA = (color, opacity) ->
  if (parts = color.match /^rgba\(\s*([0-9]+)\s*,\s*([0-9]+)\s*,\s*([0-9]+)\s*,\s*([0-9]+)\)/)
    result = "rgba(#{r},#{g},#{b},#{opacity})"
  else if (v = d3.rgb color)
    result = "rgba(#{v.r},#{v.g},#{v.b},#{opacity})"
  return result

# Tick formatter identity.
Epoch.Formats.regular = (d) -> d

# Tick formatter that formats the numbers using standard SI postfixes.
Epoch.Formats.si = (d) -> Epoch.Util.formatSI(d)

# Tick formatter for percentages.
Epoch.Formats.percent = (d) -> (d*100).toFixed(1) + "%"

# Tick formatter for seconds from timestamp data.
Epoch.Formats.seconds = (t) -> d3Seconds(new Date(t*1000))
d3Seconds = d3.time.format('%I:%M:%S %p')

# Tick formatter for bytes
Epoch.Formats.bytes = (d) -> Epoch.Util.formatBytes(d)

# Simple DOM querying, lookup, and mutation module. Created to remove the dependency on jQuery.
Epoch.Query = do ->
  queryAll = (selector) ->
    document.querySelectorAll(selector)

  getComputedStyle = (element, pseudoElement) ->
    if Epoch.isFunction(window.getComputedStyle)
      window.getComputedStyle(element, pseudoElement)
    else if element.currentStyle?
      element.currentStyle

  class Context
    getDimension = (name, index=0) ->
      return null unless @_hasIndex(index)
      element = @get(index)
      style = getComputedStyle(element, null)[name]
      parseInt( style.substr(0, style.length-2) )

    constructor: (@options={}) ->
      if @options.element?
        @elements = [@options.element]
      else if @options.selector?
        @elements = queryAll(@options.selector)

    _hasElements: ->
      @elements.length > 0

    _hasIndex: (index) ->
      @_hasElements() and index > -1 and index < @elements.length

    get: (index=0) ->
      return null unless @_hasIndex(index)
      @elements[index]

    width: (index) ->
      getDimension.call @, 'width', index

    height: (index) ->
      getDimension.call @, 'height', index

    css: (name, value, index=0) ->
      return null unless @_hasIndex(index)

      if Epoch.isString(name) and not value?
        return getComputedStyle( @get(index), null )[name]
      else if Epoch.isString(name)
        el.style[name] = value for el in @elements
      else if Epoch.isObject(name)
        for key, value of name
          el.style[key] = value for el in @elements

      return @

    append: (element, index=0) ->
      return null unless @_hasIndex(index)
      if element instanceof Context
        @elements[index].appendChild(element.get(0))
      else if Epoch.isElement(element)
        @elements[index].appendChild(element)
      return @

    attr: (name, value, index=0) ->
      return null unless @_hasIndex(index)

      if Epoch.isString(name) and value?
        el[name] = value for el in @elements
      else if Epoch.isString(name)
        return @get(index)[name]
      else if Epoch.isObject(name)
        for key, value of name
          el[name] = value for el in @elements
      return @

    data: (key, value, index=0) ->
      return null unless @_hasIndex(index)
      if value?
        el["data-#{key}"] = value for el in @elements
        return @
      @elements[index]["data-#{key}"]

    remove: ->
      el.parentNode.removeChild(el) for el in @elements

    html: (string) ->
      return null unless @_hasElements()
      el.innerHTML = string for el in @elements

  Query = (selector) ->
    return null unless selector?
    if Epoch.isString(selector)
      new Context {selector: selector}
    else if Epoch.isElement(selector)
      new Context {element: selector}
    else if selector instanceof Context
      selector

  return Query



# Basic eventing base class for all Epoch classes.
class Epoch.Events
  constructor: ->
    @_events = {}

  # Registers a callback to a given event.
  # @param [String] name Name of the event.
  # @param [Function, String] callback Either a closure to call when the event fires
  #   or a string that denotes a method name to call on this object.
  on: (name, callback) ->
    return unless callback?
    @_events[name] ?= []
    @_events[name].push callback

  # Removes a specific callback listener or all listeners for a given event.
  # @param [String] name Name of the event.
  # @param [Function, String] callback (Optional) Callback to remove from the listener list.
  #   If this parameter is not provided then all listeners will be removed for the event.
  off: (name, callback) ->
    return unless Epoch.isObject(@_events[name])
    return delete(@_events[name]) unless callback?
    while (i = @_events[name].indexOf(callback)) >= 0
      @_events[name].splice(i, 1)

  # Triggers an event causing all active listeners to be executed.
  # @param [String] name Name of the event to fire.
  trigger: (name) ->
    return unless @_events[name]?
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


# The base class for all charts in Epoch. Defines chart dimensions, keeps a reference
# of the chart's containing elements. And defines core method for handling data and
# drawing.
class Epoch.Chart.Base extends Epoch.Events
  defaults =
    width: 320
    height: 240

  # Creates a new base chart.
  # @param [Object] options Options to set for this chart.
  # @option options [Integer] width Sets an explicit width for the visualization (optional).
  # @option options [Integer] height Sets an explicit height for the visualization (optional).
  constructor: (@options) ->
    super()

    @setData(@options.data or [])

    @el = Epoch.Query(@options.el) if @options.el?

    @width = @options.width
    @height = @options.height

    if @el?
      @width = @el.width() unless @width?
      @height = @el.height() unless @height?
    else
      @width = defaults.width unless @width?
      @height = defaults.height unless @height?

  # Determines if the chart is currently visible in a document.
  # @return [Boolean] True if the chart is visible, false otherwise.
  isVisible: ->
    return true
    #return false unless @el?
    #@el.is('*:visible')

  # Set the initial data for the chart.
  # @param data Data to initially set for the given chart. The data format can vary
  #   from chart to chart. The base class assumes that the data provided will be an
  #   array of layers.
  setData: (data) ->
    category = 1
    for layer in data
      classes = ['layer']
      classes.push "category#{category}"
      layer.category = category
      classes.push(Epoch.Util.dasherize layer.label) if layer.label?        
      layer.className = classes.join(' ')
      category++

    @data = data

  # Updates the chart with new data.
  # @param data Data to replace the current data for the chart.
  # @param [Boolean] draw Whether or not to redraw the chart after the data has been set.
  #   Default: true.
  update: (data, draw=true) ->
    @setData data
    @draw() if draw

  # Draws the chart.
  # @abstract Must be overriden in child classes to perform chart specific drawing.
  draw: ->

  # Calculates an extent throughout the layers based on the given comparator.
  # @param [Function] cmp Comparator to use for performing the min and max for the extent
  #   calculation.
  # @return [Array] an extent array with the first element as the minimum value in the
  #   chart's data set and the second element as the maximum.
  extent: (cmp) ->
    [
      d3.min(@data, (layer) -> d3.min(layer.values, cmp)),
      d3.max(@data, (layer) -> d3.max(layer.values, cmp))
    ]


# Base class for all SVG charts (via d3).
class Epoch.Chart.SVG extends Epoch.Chart.Base
  # Initializes the chart and places the rendering SVG in the specified HTML
  # containing element.
  # @param [Object] options Options for the SVG chart.
  # @option options [HTMLElement] el Container element for the chart.
  # @option options [Array] data Layered data used to render the chart.
  constructor: (@options={}) ->
    super(@options)
    if @el?
      @svg = d3.select(@el.get(0)).append('svg')
    else
      @svg = d3.select(document.createElement('svg'))
    @svg.attr
        xmlns: 'http://www.w3.org/2000/svg',
        width: @width,
        height: @height

# Base Class for all Canvas based charts.
class Epoch.Chart.Canvas extends Epoch.Chart.Base
  # Initializes the chart and places the rendering canvas in the specified
  # HTML container element.
  # @param [Object] options Options for the SVG chart.
  # @option options [HTMLElement] el Container element for the chart.
  # @option options [Array] data Layered data used to render the chart.
  constructor: (@options={}) ->
    super(@options)
    @canvas = Epoch.Query( document.createElement('CANVAS') )

    if @options.pixelRatio?
      @pixelRatio = @options.pixelRatio
    else if window.devicePixelRatio?
      @pixelRatio = window.devicePixelRatio
    else
      @pixelRatio = 1

    @canvas.css
      'width': "#{@width}px"
      'height': "#{@height}px"

    @canvas.attr('width', @width * @pixelRatio).attr('height', @height * @pixelRatio)
    @el.append(@canvas) if @el?
    @ctx = @canvas.get(0).getContext('2d')

  # @return [Number] width of the canvas with respect to the pixel ratio of the display
  getWidth: -> @width * @pixelRatio

  # @return [Number] height of the canvas with respect to the pixel ratio of the display
  getHeight: -> @height * @pixelRatio

  # Clears the render canvas.
  clear: ->
    @ctx.clearRect(0, 0, @getWidth(), @getHeight())

  # @return [Object] computed styles for the given selector in the context of this chart.
  # @param [String] selector The selector used to compute the styles.
  getStyles: (selector) ->
    QueryCSS.getStyles(selector, @el)


# Singelton class used to query CSS styles by way of reference elements.
# This allows canvas based visualizations to use the same styles as their
# SVG counterparts.
class QueryCSS
  # Reference container id
  REFERENCE_CONTAINER_ID = '_canvas_css_reference'

  # Handles automatic container id generation
  containerCount = 0
  nextContainerId = -> "epoch-container-#{containerCount++}"

  # Key-Value cache for computed styles that we found using this class.
  @cache = {}

  # List of styles to pull from the full list of computed styles
  @styleList = ['fill', 'stroke', 'stroke-width']

  # The svg reference container
  @container = null

  # Purges the selector to style cache
  @purge: ->
    QueryCSS.cache = {}

  # Gets the reference element container.
  @getContainer: ->
    return QueryCSS.container if QueryCSS.container?
    container = document.createElement('DIV')
    container.id = REFERENCE_CONTAINER_ID
    document.body.appendChild(container)
    QueryCSS.container = Epoch.Query(container)

  # @return [String] A unique identifier for the given container and selector.
  # @param [String] selector Selector from which to derive the styles
  # @param container The containing element for a chart.
  @hash: (selector, container) ->
    containerId = Epoch.Query(container).data('epoch-container-id')
    unless containerId?
      containerId = nextContainerId()
      Epoch.Query(container).data('epoch-container-id', containerId)
    return "#{containerId}__#{selector}"

  # @return The computed styles for the given selector in the given container element.
  # @param [String] selector Selector from which to derive the styles.
  # @param container HTML containing element in which to place the reference SVG.
  @getStyles: (selector, container) ->
    # 0) Check for cached styles
    cacheKey = QueryCSS.hash(selector, container)
    cache = QueryCSS.cache[cacheKey]
    return cache if cache?

    # 1) Build a full reference tree (parents, container, and selector elements)
    parents = []
    parentNode = container.get(0).parentNode

    while parentNode? and parentNode.nodeName.toLowerCase() != 'body'
      parents.unshift parentNode
      parentNode = parentNode.parentNode
    parents.push container.get(0)

    selectorList = []
    for element in parents
      sel = element.nodeName.toLowerCase()
      if element.id? and element.id.length > 0
        sel += '#' + element.id
      if element.className? and element.className.length > 0
        sel += '.' + Epoch.Util.trim(element.className).replace(/\s+/g, '.')
      selectorList.push sel

    selectorList.push('svg')

    for subSelector in Epoch.Util.trim(selector).split(/\s+/)
      selectorList.push(subSelector)

    parent = root = put(selectorList.shift())
    while selectorList.length
      el = put(selectorList.shift())
      parent.appendChild el
      parent = el

    # 2) Place the reference tree and fetch styles given the selector
    QueryCSS.getContainer().append(root)
    ref = Epoch.Query('#' + REFERENCE_CONTAINER_ID + ' ' + selector)
    styles = {}
    for name in QueryCSS.styleList
      styles[name] = ref.css(name)
    QueryCSS.cache[cacheKey] = styles

    # 3) Cleanup and return the styles
    QueryCSS.getContainer().html('')
    return styles


Epoch.QueryCSS = QueryCSS

# "I think, baby, I was born just a little late!" -- Middle Class Rut
