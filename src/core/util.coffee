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
  if (parts = color.match /^rgba\(\s*([0-9]+)\s*,\s*([0-9]+)\s*,\s*([0-9]+)\s*,\s*([0-9]+)\)/)
    result = "rgba(#{r},#{g},#{b},#{opacity})"
  else if (v = d3.rgb color)
    result = "rgba(#{v.r},#{v.g},#{v.b},#{opacity})"
  return result
