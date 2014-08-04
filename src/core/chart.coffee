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
    @on(name, callback) for name, callback of map

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
      @off(name, callback) for name, callback of mapOrList

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

  optionListeners =
    'option:width': 'dimensionsChanged'
    'option:height': 'dimensionsChanged'
    'layer:shown': 'layerChanged'
    'layer:hidden': 'layerChanged'

  # Creates a new base chart.
  # @param [Object] options Options to set for this chart.
  # @option options [Integer] width Sets an explicit width for the visualization (optional).
  # @option options [Integer] height Sets an explicit height for the visualization (optional).
  constructor: (@options={}) ->
    super()

    @setData(@options.data or [])
    @el = d3.select(@options.el) if @options.el?
    @width = @options.width
    @height = @options.height

    if @el?
      @width = @el.width() unless @width?
      @height = @el.height() unless @height?
    else
      @width = defaults.width unless @width?
      @height = defaults.height unless @height?

    @onAll optionListeners

  # @return [Object] A copy of this charts options.
  _getAllOptions: ->
    Epoch.Util.defaults({}, @options)

  # Chart option accessor.
  # @param key Name of the option to fetch. Can be hierarchical, e.g. 'margins.left'
  # @return The requested option if found, undefined otherwise.
  _getOption: (key) ->
    parts = key.split('.')
    scope = @options
    while parts.length and scope?
      subkey = parts.shift()
      scope = scope[subkey]
    scope

  # Chart option mutator.
  # @param key Name of the option to fetch. Can be hierarchical, e.g. 'margins.top'
  # @param value Value to set for the option.
  # @event option:`key` Triggers an option event with the given key being set.
  _setOption: (key, value) ->
    parts = key.split('.')
    scope = @options
    while parts.length
      subkey = parts.shift()
      if parts.length == 0
        scope[subkey] = arguments[1]
        @trigger "option:#{arguments[0]}"
        return
      unless scope[subkey]?
        scope[subkey] = {}
      scope = scope[subkey]

  # Sets all options given an object of mixed hierarchical keys and nested objects.
  # @param [Object] options Options to set.
  # @event option:* Triggers an option event for each key that was set
  _setManyOptions: (options, prefix='') ->
    for key, value of options
      if Epoch.isObject(value)
        @_setManyOptions value, "#{prefix + key}."
      else
        @_setOption prefix + key, value

  # General accessor / mutator for chart options.
  #
  # @overload option()
  #   Fetches chart options.
  #   @return a copy of this chart's options.
  #
  # @overload option(name)
  #   Fetches the value the option with the given name.
  #   @param [String] name Name of the option to fetch. Can be hierarchical, e.g. <code>'margins.left'</code>
  #   @return The requested option if found, <code>undefined</code> otherwise.
  #
  # @overload option(name, value)
  #   Sets an option and triggers the associated event.
  #   @param [String] name Name of the option to fetch. Can be hierarchical, e.g. 'margins.top'
  #   @param value Value to set for the option.
  #   @event option:`name` Triggers an option event with the given key being set.
  #
  # @overload option(options)
  #   Sets multiple options at once.
  #   @param [Object] options Options to set for the chart.
  #   @event option:* Triggers an option event for each key that was set. 
  option: ->
    if arguments.length == 0
      @_getAllOptions()
    else if arguments.length == 1 and Epoch.isString(arguments[0])
      @_getOption arguments[0]
    else if arguments.length == 2 and Epoch.isString(arguments[0])
      @_setOption arguments[0], arguments[1]
    else if arguments.length == 1 and Epoch.isObject(arguments[0])
      @_setManyOptions arguments[0]

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
      layer.visible = true
      classes.push(Epoch.Util.dasherize layer.label) if layer.label?
      layer.className = classes.join(' ')
      category++

    @data = data

  # Finds a layer in the chart's current data that has the given label or index.
  # @param [String, Number] labelOrIndex The label or index of the layer to find.
  _findLayer: (labelOrIndex) ->
    layer = null
    if Epoch.isString(labelOrIndex)
      for l in @data
        if l.label == labelOrIndex
          layer = l
          break
    else if Epoch.isNumber(labelOrIndex)
      index = parseInt(labelOrIndex)
      layer = @data[index] unless index < 0 or index >= @data.length
    return layer

  # Instructs the chart that a data layer should be displayed.
  # @param [String, Number] labelOrIndex The label or index of the layer to show.
  # @event 'layer:shown' If a layer that was previously hidden now became visible.
  showLayer: (labelOrIndex) ->
    return unless (layer = @_findLayer labelOrIndex)
    return if layer.visible
    layer.visible = true
    @trigger 'layer:shown'

  # Instructs the chart that a data layer should not be displayed.
  # @param [String, Number] labelOrIndex The label or index of the layer to hide.
  # @event 'layer:hidden' If a layer that was visible was made hidden.
  hideLayer: (labelOrIndex) ->
    return unless (layer = @_findLayer labelOrIndex)
    return unless layer.visible
    layer.visible = false
    @trigger 'layer:hidden'

  # Instructs the chart that a data layer's visibility should be toggled.
  # @param [String, Number] labelOrIndex The label or index of the layer to toggle.
  # @event 'layer:shown' If the layer was made visible
  # @event 'layer:hidden' If the layer was made invisible
  toggleLayer: (labelOrIndex) ->
    return unless (layer = @_findLayer labelOrIndex)
    layer.visible = !layer.visible
    if layer.visible
      @trigger 'layer:shown'
    else
      @trigger 'layer:hidden'

  # Determines whether or not a data layer is visible.
  # @param [String, Number] labelOrIndex The label or index of the layer to toggle.
  # @return <code>true</code> if the layer is visible, <code>false</code> otherwise.
  isLayerVisible: (labelOrIndex) ->
    return null unless (layer = @_findLayer labelOrIndex)
    layer.visible

  # Calculates an array of layers in the charts data that are flagged as visible.
  # @return [Array] The chart's visible layers.
  getVisibleLayers: ->
    visible = []
    for layer in @data
      visible.push(layer) if layer.visible
    return visible

  # Updates the chart with new data.
  # @param data Data to replace the current data for the chart.
  # @param [Boolean] draw Whether or not to redraw the chart after the data has been set.
  #   Default: true.
  update: (data, draw=true) ->
    @setData data
    @draw() if draw

  # Draws the chart. Triggers the 'draw' event, subclasses should call super() after drawing to 
  # ensure that the event is triggered.
  # @abstract Must be overriden in child classes to perform chart specific drawing.
  draw: -> @trigger 'draw'

  # Calculates an extent throughout the layers based on the given comparator.
  # @param [Function] cmp Comparator to use for performing the min and max for the extent
  #   calculation.
  # @return [Array] an extent array with the first element as the minimum value in the
  #   chart's data set and the second element as the maximum.
  extent: (cmp) ->
    [
      d3.min(@getVisibleLayers(), (layer) -> d3.min(layer.values, cmp)),
      d3.max(@getVisibleLayers(), (layer) -> d3.max(layer.values, cmp))
    ]

  # Updates the width and height members and container dimensions in response to an
  # 'option:width' or 'option:height' event.
  dimensionsChanged: ->
    @width = @option('width') or @width
    @height = @option('height') or @height
    @el.width(@width)
    @el.height(@height)

  # Updates the chart in response to a layer being shown or hidden
  layerChanged: ->
    @draw()

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
      @svg = @el.append('svg')
    else
      @svg = d3.select(document.createElement('svg'))
    @svg.attr
        xmlns: 'http://www.w3.org/2000/svg',
        width: @width,
        height: @height

  # Resizes the svg element in response to a 'option:width' or 'option:height' event.
  dimensionsChanged: ->
    super()
    @svg.attr('width', @width).attr('height', @height)

# Base Class for all Canvas based charts.
class Epoch.Chart.Canvas extends Epoch.Chart.Base
  # Initializes the chart and places the rendering canvas in the specified
  # HTML container element.
  # @param [Object] options Options for the SVG chart.
  # @option options [HTMLElement] el Container element for the chart.
  # @option options [Array] data Layered data used to render the chart.
  constructor: (@options={}) ->
    super(@options)

    if @options.pixelRatio?
      @pixelRatio = @options.pixelRatio
    else if window.devicePixelRatio?
      @pixelRatio = window.devicePixelRatio
    else
      @pixelRatio = 1

    @canvas = d3.select( document.createElement('CANVAS') )
    @canvas.style
      'width': "#{@width}px"
      'height': "#{@height}px"

    @canvas.attr
      width: @getWidth()
      height: @getHeight()

    @el.node().appendChild @canvas.node() if @el?
    @ctx = Epoch.Util.getContext @canvas.node()

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
    Epoch.QueryCSS.getStyles(selector, @el)

  # Resizes the canvas element when the dimensions of the container change
  dimensionsChanged: ->
    super()
    @canvas.style {'width': "#{@width}px", 'height': "#{@height}px"}
    @canvas.attr { width: @getWidth(), height: @getHeight() }
