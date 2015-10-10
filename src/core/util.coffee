typeFunction = (objectName) -> (v) ->
  Object::toString.call(v) == "[object #{objectName}]"

# @return [Boolean] <code>true</code> if the given value is an array, <code>false</code> otherwise.
# @param v Value to test.
Epoch.isArray = Array.isArray ? typeFunction('Array')

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

# Determines if a given value is a non-empty array.
# @param v Value to test.
# @return [Boolean] <code>true</code> if the given value is an array with at least one element.
Epoch.isNonEmptyArray = (v) ->
  Epoch.isArray(v) and v.length > 0

# Generates shallow copy of an object.
# @return A shallow copy of the given object.
# @param [Object] original Object for which to make the shallow copy.
Epoch.Util.copy = (original) ->
  return null unless original?
  copy = {}
  copy[k] = v for own k, v of original
  return copy

# Creates a deep copy of the given options filling in missing defaults.
# @param [Object] options Options to copy.
# @param [Object] defaults Default values for the options.
Epoch.Util.defaults = (options, defaults) ->
  result = Epoch.Util.copy(options)
  for own k, v of defaults
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

  for own i, label of ['K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y']
    base = Math.pow(10, ((i|0)+1)*3)
    if v >= base and v < Math.pow(10, ((i|0)+2)*3)
      q = v/base
      q = q.toFixed(fixed) unless (q % 1) == 0 and !fixIntegers
      return "#{q} #{label}"

# Formats large bandwidth and disk space usage numbers with byte postfixes (e.g. KB, MB, GB, etc.)
# @param [Number] v Value to format.
# @param [Integer] fixed Number of floating point digits to fix after conversion.
# @param [Boolean] fixIntegers Whether or not to add floating point digits to non-floating point results.
# @example Formatting a large number of bytes
#   Epoch.Util.formatBytes(5.21 * Math.pow(2, 20)) == "5.2 MB"
Epoch.Util.formatBytes = (v, fixed=1, fix_integers=false) ->
  if v < 1024
    q = v
    q = q.toFixed(fixed) unless (q % 1) == 0 and !fix_integers
    return "#{q} B"

  for own i, label of ['KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB']
    base = Math.pow(1024, (i|0)+1)
    if v >= base and v < Math.pow(1024, (i|0)+2)
      q = v/base
      q = q.toFixed(fixed) unless (q % 1) == 0 and !fix_integers
      return "#{q} #{label}"

# @return a "dasherized" css class names from a given string
# @example Using dasherize
#   Epoch.Util.dasherize('My Awesome Name') == 'my-awesome-name'
Epoch.Util.dasherize = (str) ->
  Epoch.Util.trim(str).replace("\n", '').replace(/\s+/g, '-').toLowerCase()

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

# Returns the computed styles of an element in the document
# @param [HTMLElement] Element for which to fetch the styles.
# @param [String] pseudoElement Pseudo selectors on which to search for the element.
# @return [Object] The styles for the given element.
Epoch.Util.getComputedStyle = (element, pseudoElement) ->
  if Epoch.isFunction(window.getComputedStyle)
    window.getComputedStyle(element, pseudoElement)
  else if element.currentStyle?
    element.currentStyle

# Converts a CSS color string into an RGBA string with the given opacity
# @param [String] color Color string to convert into an rgba
# @param [Number] opacity Opacity to use for the resulting color.
# @return the resulting rgba color string.
Epoch.Util.toRGBA = (color, opacity) ->
  if (parts = color.match /^rgba\(\s*([0-9]+)\s*,\s*([0-9]+)\s*,\s*([0-9]+)\s*,\s*[0-9\.]+\)/)
    [all, r, g, b] = parts
    result = "rgba(#{r},#{g},#{b},#{opacity})"
  else if (v = d3.rgb color)
    result = "rgba(#{v.r},#{v.g},#{v.b},#{opacity})"
  return result

# Obtains a graphics context for the given canvas node. Nice to have
# this abstracted out in case we want to support WebGL in the future.
# Also allows us to setup a special context when unit testing, as
# jsdom doesn't have canvas support, and node-canvas is a pain in the
# butt to install properly across different platforms.
Epoch.Util.getContext = (node, type='2d') ->
  node.getContext(type)

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

  # Registers a map of event names to given callbacks. This method calls <code>.on</code>
  # directly for each of the events given.
  # @param [Object] map A map of event names to callbacks.
  onAll: (map) ->
    return unless Epoch.isObject(map)
    @on(name, callback) for own name, callback of map

  # Removes a specific callback listener or all listeners for a given event.
  # @param [String] name Name of the event.
  # @param [Function, String] callback (Optional) Callback to remove from the listener list.
  #   If this parameter is not provided then all listeners will be removed for the event.
  off: (name, callback) ->
    return unless Epoch.isArray(@_events[name])
    return delete(@_events[name]) unless callback?
    while (i = @_events[name].indexOf(callback)) >= 0
      @_events[name].splice(i, 1)

  # Removes a set of callback listeners for all events given in the map or array of strings.
  # This method calls <code>.off</code> directly for each event and callback to remove.
  # @param [Object, Array] mapOrList Either a map that associates event names to specific callbacks
  #   or an array of event names for which to completely remove listeners.
  offAll: (mapOrList) ->
    if Epoch.isArray(mapOrList)
      @off(name) for name in mapOrList
    else if Epoch.isObject(mapOrList)
      @off(name, callback) for own name, callback of mapOrList

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

# Performs a single pass flatten on a multi-array
# @param [Array] multiarray A deep multi-array to flatten
# @returns [Array] A single pass flatten of the multi-array
Epoch.Util.flatten = (multiarray) ->
  if !Array.isArray(multiarray)
    throw new Error('Epoch.Util.flatten only accepts arrays')
  result = []
  for array in multiarray
    if Array.isArray(array)
      for item in array
        result.push item
    else
      result.push array
  result
