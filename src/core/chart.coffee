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
    return unless Epoch.isArray(@_events[name])
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

  trigger_options = (instance, scope, prefix) ->
    for key, value of scope
      if Epoch.isObject(value)
        trigger_options(instance, value, prefix + '.' + key) 
      else if prefix.length > 0
        instance.trigger "option:#{prefix.substr(1)}.#{key}"
      else
        instance.trigger "option:#{key}"
        

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

  # Gets and sets chart options after initialization. When using this as a setter, if an
  # option actually changes value then an event <code>option:NAME</code> will be triggered
  # where NAME is the name of the option.
  #
  # This method can be called in four different ways:
  # <ol>
  #   <li>chart.option() - Returns a an object containing all of the options for the chart.</li>
  #   <li>chart.option(key) - Returns a specific option. Use <code>.</code> to access nested options.</li>
  #   <li>chart.option(key, value) - Sets an option and triggers the associated event.</li>
  #   <li>chart.option(object) - Allows for the setting of multiple options at once.</li>
  # </ol>
  #
  # Warning: This method is currently experimental, and is not used by any core part of the library.
  #   I'd feel much safer with real unit tests in place before proceeding to build around it.
  option: ->
    # No Arguments: Return a copy of this chart's options
    if arguments.length == 0
      return Epoch.Util.defaults({}, @options) 

    # Get the option with the given key
    if arguments.length == 1 and Epoch.isString(arguments[0])
      parts = arguments[0].split('.')
      scope = @options
      while parts.length and scope?
        subkey = parts.shift()
        scope = scope[subkey]
      return scope

    # Set an option with the specified key to a specified value
    if arguments.length == 2 and Epoch.isString(arguments[0])
      parts = arguments[0].split('.')
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

    # Set new options given an object
    if arguments.length == 1 and Epoch.isObject(arguments[0])
      @options = Epoch.Util.defaults(arguments[0], @options)
      trigger_options @, arguments[0], ''
      return

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
      @svg = @el.append('svg')
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