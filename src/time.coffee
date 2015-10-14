# Real-time Plot Base Class. Uses an html5 canvas to recreate the basic d3 drawing routines
# while simultaneously reducing the load on the viewer's cpu (and, you know, not leaking
# memory which ultimately leads to a crashed browser).
#
# The class also handles the creation of axes and margins common to all time-series plots.
# Furthermore it layers the canvas below an SVG element to keep visual consistency when
# rendering text, glyphs, etc.
class Epoch.Time.Plot extends Epoch.Chart.Canvas
  defaults =
    range: null
    fps: 24
    historySize: 120
    windowSize: 40
    queueSize: 10
    axes: ['bottom']
    ticks:
      time: 15
      left: 5
      right: 5
    tickFormats:
      top: Epoch.Formats.seconds
      bottom: Epoch.Formats.seconds
      left: Epoch.Formats.si
      right: Epoch.Formats.si

  defaultAxisMargins =
    top: 25
    right: 50
    bottom: 25
    left: 50

  optionListeners =
    'option:margins': 'marginsChanged'
    'option:margins.top': 'marginsChanged'
    'option:margins.right': 'marginsChanged'
    'option:margins.bottom': 'marginsChanged'
    'option:margins.left': 'marginsChanged'
    'option:axes': 'axesChanged'
    'option:ticks': 'ticksChanged'
    'option:ticks.top': 'ticksChanged'
    'option:ticks.right': 'ticksChanged'
    'option:ticks.bottom': 'ticksChanged'
    'option:ticks.left': 'ticksChanged'
    'option:tickFormats': 'tickFormatsChanged'
    'option:tickFormats.top': 'tickFormatsChanged'
    'option:tickFormats.right': 'tickFormatsChanged'
    'option:tickFormats.bottom': 'tickFormatsChanged'
    'option:tickFormats.left': 'tickFormatsChanged'

  # Creates a new real-time plot.
  #
  # @param [Object] options Options for the plot.
  # @option options [Integer] fps Number of frames per second to use when animating
  #   the plot.
  # @option options [Integer] historySize Maximum number of elements to keep in history
  #   for the plot.
  # @option options [Integer] windowSize Number of entries to simultaneously display
  #   when rendering the visualization.
  # @option options [Integer] queueSize Number of elements to queue while not animating
  #   but still recieving elements. In some browsers, intervals will not fire if the
  #   page containing them is not the active tab. By setting a maximum limit to the
  #   number of unprocessed data points we can ensure that the memory footprint of the
  #   page does not get out of hand.
  # @option options [Object] margins Explicit margins to use for the visualization. Note
  #   that these are optional and will be automatically generated based on which axes are
  #   used for the visualization. Margins are keyed by their position (top, left, bottom
  #   and/or right) and should map to [Integer] values.
  # @option options [Array] axes Which axes to display when rendering the visualization
  #   (top, left, bottom, and/or right).
  # @option options [Object] ticks Number of ticks to display on each axis available axes
  #   ares: time, left, and right. The number provided for the left and right axes are in
  #   absolute terms (i.e. there will be exactly that number of ticks). The time ticks
  #   denote how often a tick should be generated (e.g. if 5 is provided then a tick will
  #   be added every fifth time you push a new data entry into the visualization).
  # @option options [Object] tickFormats Formatting functions for ticks on the given axes.
  #   The avaiable axes are: top, bottom, left, and right.
  constructor: (@options) ->
    givenMargins = Epoch.Util.copy(@options.margins) or {}
    super(@options = Epoch.Util.defaults(@options, defaults))

    if @options.model
      @options.model.on 'data:push', => @pushFromModel()

    # Queue entering data to get around memory bloat and "non-active" tab issues
    @_queue = []

    # Margins
    @margins = {}
    for pos in ['top', 'right', 'bottom', 'left']
      @margins[pos] = if @options.margins? and @options.margins[pos]?
        @options.margins[pos]
      else if @hasAxis(pos)
        defaultAxisMargins[pos]
      else
        6

    # SVG Overlay
    @svg = @el.insert('svg', ':first-child')
      .attr('width', @width)
      .attr('height', @height)
      .style('z-index', '1000')

    # Position the canvas "under" the SVG element
    if @el.style('position') != 'absolute' and @el.style('position') != 'relative'
      @el.style('position', 'relative')

    @canvas.style { position: 'absolute', 'z-index': '999' }
    @_sizeCanvas()

    # Animation / Transitions
    @animation =
      interval: null
      active: false
      delta: => -(@w() / @options.fps),
      tickDelta: => -( (@w() / @pixelRatio) / @options.fps )
      frame: 0,
      duration: @options.fps

    # Add SVG Axes
    @_buildAxes()

    # Callback used for animation
    @animationCallback = => @_animate()

    # Listen for specific option changes
    @onAll optionListeners

  # Positions and sizes the canvas based on margins and axes.
  _sizeCanvas: ->
    @canvas.attr
      width: @innerWidth()
      height: @innerHeight()

    @canvas.style
      width: "#{@innerWidth() / @pixelRatio}px"
      height: "#{@innerHeight() / @pixelRatio}px"
      top: "#{@margins.top}px"
      left: "#{@margins.left}px"

  # Removes any axes found in the SVG and adds both the time and range axes to the plot.
  _buildAxes: ->
    @svg.selectAll('.axis').remove()
    @_prepareTimeAxes()
    @_prepareRangeAxes()

  # Works exactly as in Epoch.Chart.Base with the addition of truncating value arrays
  # to that of the historySize defined in the chart's options.
  _annotateLayers: (prepared) ->
    data = []
    for own i, layer of prepared
      copy = Epoch.Util.copy(layer)
      start = Math.max(0, layer.values.length - @options.historySize)
      copy.values = layer.values.slice(start)
      classes = ['layer']
      classes.push "category#{(i|0)+1}"
      classes.push(Epoch.Util.dasherize layer.label) if layer.label?
      copy.className = classes.join(' ')
      copy.visible = true
      data.push copy
    return data

  # This method is called to provide a small offset for placement of horizontal ticks.
  # The value returned will be added to the x value of each tick as they are being
  # rendered.
  #
  # @return [Number] The horizontal offset for the top and bottom axes ticks.
  _offsetX: -> 0

  # Builds time axes (bottom and top)
  _prepareTimeAxes: ->
    if @hasAxis('bottom')
      axis = @bottomAxis = @svg.append('g')
        .attr('class', "x axis bottom canvas")
        .attr('transform', "translate(#{@margins.left-1}, #{@innerHeight()/@pixelRatio+@margins.top})")
      axis.append('path')
        .attr('class', 'domain')
        .attr('d', "M0,0H#{@innerWidth()/@pixelRatio+1}")

    if @hasAxis('top')
      axis = @topAxis = @svg.append('g')
        .attr('class', "x axis top canvas")
        .attr('transform', "translate(#{@margins.left-1}, #{@margins.top})")
      axis.append('path')
        .attr('class', 'domain')
        .attr('d', "M0,0H#{@innerWidth()/@pixelRatio+1}")

    @_resetInitialTimeTicks()

  # Resets the initial ticks for the time axes.
  _resetInitialTimeTicks: ->
    tickInterval = @options.ticks.time
    @_ticks = []
    @_tickTimer = tickInterval

    @bottomAxis.selectAll('.tick').remove() if @bottomAxis?
    @topAxis.selectAll('.tick').remove() if @topAxis?

    for layer in @data
      continue unless Epoch.isNonEmptyArray(layer.values)
      [i, k] = [@options.windowSize-1, layer.values.length-1]
      while i >= 0 and k >= 0
        @_pushTick i, layer.values[k].time, false, true
        i -= tickInterval
        k -= tickInterval
      break

  # Builds the range axes (left and right)
  _prepareRangeAxes: ->
    if @hasAxis('left')
      @svg.append("g")
        .attr("class", "y axis left")
        .attr('transform', "translate(#{@margins.left-1}, #{@margins.top})")
        .call(@leftAxis())

    if @hasAxis('right')
      @svg.append('g')
        .attr('class', 'y axis right')
        .attr('transform', "translate(#{@width - @margins.right}, #{@margins.top})")
        .call(@rightAxis())

  # @return [Object] The d3 left axis.
  leftAxis: ->
    ticks = @options.ticks.left
    axis = d3.svg.axis().scale(@ySvgLeft()).orient('left')
      .tickFormat(@options.tickFormats.left)
    if ticks == 2
      axis.tickValues @extent((d) -> d.y)
    else
      axis.ticks(ticks)

  # @return [Object] The d3 right axis.
  rightAxis: ->
    extent = @extent((d) -> d.y)
    ticks = @options.ticks.right
    axis = d3.svg.axis().scale(@ySvgRight()).orient('right')
      .tickFormat(@options.tickFormats.right)
    if ticks == 2
      axis.tickValues @extent((d) -> d.y)
    else
      axis.ticks(ticks)

  # Determines if the visualization is displaying the axis with the given name.
  # @param [String] name Name of the axis
  # @return [Boolean] <code>true</code> if the axis was set in the options, <code>false</code> otherwise.
  hasAxis: (name) ->
    @options.axes.indexOf(name) > -1

  # @return [Number] the width of the visualization area of the plot (full width - margins)
  innerWidth: ->
    (@width - (@margins.left + @margins.right)) * @pixelRatio

  # @return [Number] the height of the visualization area of the plot (full height - margins)
  innerHeight: ->
    (@height - (@margins.top + @margins.bottom)) * @pixelRatio

  # Abstract method for performing any preprocessing before queuing new entries
  # @param entry [Object] The entry to prepare.
  # @return [Object] The prepared entry.
  _prepareEntry: (entry) -> entry

  # Abstract method for preparing a group of layered entries entering the visualization
  # @param [Array] layers The layered entries to prepare.
  # @return [Array] The prepared layers.
  _prepareLayers: (layers) -> layers

  # This method will remove the first incoming entry from the visualization's queue
  # and shift it into the working set (aka window). It then starts the animating the
  # transition of the element into the visualization.
  # @event transition:start in the case that animation is actually started.
  _startTransition: ->
    return if @animation.active == true or @_queue.length == 0
    @trigger 'transition:start'
    @_shift()
    @animation.active = true
    @animation.interval = setInterval(@animationCallback, 1000/@options.fps)

  # Stops animating and clears the animation interval given there is no more
  # incoming data to process. Also finalizes tick entering and exiting.
  # @event transition:end After the transition has completed.
  _stopTransition: ->
    return unless @inTransition()

    # Shift data off the end
    for layer in @data
      continue unless layer.values.length > @options.windowSize + 1
      layer.values.shift()

    # Finalize tick transitions
    [firstTick, lastTick] = [@_ticks[0], @_ticks[@_ticks.length-1]]

    if lastTick? and lastTick.enter
      lastTick.enter = false
      lastTick.opacity = 1

    if firstTick? and firstTick.exit
      @_shiftTick()

    # Reset the animation frame modulus
    @animation.frame = 0

    # Trigger that we are done transitioning
    @trigger 'transition:end'

    # Clear the transition interval unless another entry is already queued
    if @_queue.length > 0
      @_shift()
    else
      @animation.active = false
      clearInterval @animation.interval

  # Determines if the plot is currently animating a transition.
  # @return [Boolean] <code>true</code> if the plot is animating, <code>false</code> otherwise.
  inTransition: ->
    @animation.active

  # This method is used by the application programmer to introduce new data into
  # the timeseries plot. The method queues the incoming data, ensures a fixed size
  # for the data queue, and finally calls <code>_startTransition</code> method to
  # begin animating the plot.
  # @param [Array] layers Layered incoming visualization data.
  # @event push Triggered after the new data has been pushed into the queue.
  push: (layers) ->
    layers = @_prepareLayers(layers)

    # Handle entry queue maximum size
    if @_queue.length > @options.queueSize
      @_queue.splice @options.queueSize, (@_queue.length - @options.queueSize)
    return false if @_queue.length == @options.queueSize

    # Push the entry into the queue
    @_queue.push layers.map((entry) => @_prepareEntry(entry))

    @trigger 'push'

    # Begin the transition unless we are already doing so
    @_startTransition() unless @inTransition()

  # Fetches new entry data from the model in response to a 'data:push' event.
  pushFromModel: ->
    @push @options.model.getNext(@options.type, @options.dataFormat)

  # Shift elements off the incoming data queue (see the implementation of
  # push above).
  #
  # If there's data to be shoved into the visualization it will pull it
  # off the queue and put it into the working dataset. It also calls through
  # to @_updateTicks to handle horizontal (or "time") axes tick transitions
  # since we're implementing independent of d3 as well.
  #
  # @event before:shift Before an element has been shifted off the queue.
  # @event after:shift After the element has been shifted off the queue.
  _shift: ->
    @trigger 'before:shift'
    entry = @_queue.shift()
    layer.values.push(entry[i]) for own i, layer of @data
    @_updateTicks(entry[0].time)
    @_transitionRangeAxes()
    @trigger 'after:shift'

  # Transitions the left and right axes when the range of the plot has changed.
  _transitionRangeAxes: ->
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

  # Performs the animation for transitioning elements in the visualization.
  _animate: ->
    return unless @inTransition()
    @_stopTransition() if ++@animation.frame == @animation.duration
    @draw(@animation.frame * @animation.delta())
    @_updateTimeAxes()

  # @param [Array] givenDomain A given domain for the scale
  # @return [Function] The y scale for the plot
  y: (givenDomain) ->
    d3.scale.linear()
      .domain(@_getScaleDomain(givenDomain))
      .range([@innerHeight(), 0])

  # @param [Array] givenDomain Optional domain to override default
  # @return [Function] The y scale for the svg portions of the plot
  ySvg: (givenDomain) ->
    d3.scale.linear()
      .domain(@_getScaleDomain(givenDomain))
      .range([@innerHeight() / @pixelRatio, 0])

  # @return [Function] The y scale for the svg portion of the plot for the left axis
  ySvgLeft: ->
    if @options.range?
      @ySvg @options.range.left
    else
      @ySvg()

  # @return [Function] The y scale for the svg portion of the plot for the right axis
  ySvgRight: ->
    if @options.range?
      @ySvg @options.range.right
    else
      @ySvg()

  # @return [Number] The width of a single section of the graph pertaining to a data point
  w: ->
    @innerWidth() / @options.windowSize

  # This is called every time we introduce new data (as a result of _shift)
  # it checks to see if we also need to update the working tick set and
  # makes the approriate changes for handling tick animation (enter, exit,
  # and update in the d3 model).
  #
  # @param [Integer] newTime Current newest timestamp in the data
  _updateTicks: (newTime) ->
    return unless @hasAxis('top') or @hasAxis('bottom')

    # Incoming ticks
    unless (++@_tickTimer) % @options.ticks.time
      @_pushTick(@options.windowSize, newTime, true)

    # Outgoing ticks
    return unless @_ticks.length > 0
    unless @_ticks[0].x - (@w()/@pixelRatio) >= 0
      @_ticks[0].exit = true

  # Makes and pushes a new tick into the visualization.
  #
  # @param bucket Index in the data window where the tick should initially be position
  # @param time The unix timestamp associated with the tick
  # @param enter Whether or not the tick should be considered as "newly entering"
  #        Used primarily for performing the tick opacity tween.
  _pushTick: (bucket, time, enter=false, reverse=false) ->
    return unless @hasAxis('top') or @hasAxis('bottom')
    tick =
      time: time
      x: bucket*(@w()/@pixelRatio) + @_offsetX()
      opacity: if enter then 0 else 1
      enter: if enter then true else false
      exit: false

    if @hasAxis('bottom')
      g = @bottomAxis.append('g')
        .attr('class', 'tick major')
        .attr('transform', "translate(#{tick.x+1},0)")
        .style('opacity', tick.opacity)

      g.append('line')
        .attr('y2', 6)

      g.append('text')
        .attr('text-anchor', 'middle')
        .attr('dy', 19)
        .text(@options.tickFormats.bottom(tick.time))

      tick.bottomEl = g

    if @hasAxis('top')
      g = @topAxis.append('g')
        .attr('class', 'tick major')
        .attr('transform', "translate(#{tick.x+1},0)")
        .style('opacity', tick.opacity)

      g.append('line')
        .attr('y2', -6)

      g.append('text')
        .attr('text-anchor', 'middle')
        .attr('dy', -10)
        .text(@options.tickFormats.top(tick.time))

      tick.topEl = g

    if reverse
      @_ticks.unshift tick
    else
      @_ticks.push tick
    return tick

  # Shifts a tick that is no longer needed out of the visualization.
  _shiftTick: ->
    return unless @_ticks.length > 0
    tick = @_ticks.shift()
    tick.topEl.remove() if tick.topEl?
    tick.bottomEl.remove() if tick.bottomEl?

  # This performs animations for the time axes (top and bottom).
  _updateTimeAxes: ->
    return unless @hasAxis('top') or @hasAxis('bottom')
    [dx, dop] = [@animation.tickDelta(), 1 / @options.fps]

    for tick in @_ticks
      tick.x += dx
      if @hasAxis('bottom')
        tick.bottomEl.attr('transform', "translate(#{tick.x+1},0)")
      if @hasAxis('top')
        tick.topEl.attr('transform', "translate(#{tick.x+1},0)")

      if tick.enter
        tick.opacity += dop
      else if tick.exit
        tick.opacity -= dop

      if tick.enter or tick.exit
        tick.bottomEl.style('opacity', tick.opacity) if @hasAxis('bottom')
        tick.topEl.style('opacity', tick.opacity) if @hasAxis('top')

  # Draws the visualization in the plot's canvas.
  # @param delta The current x offset to apply to all elements when rendering. This number
  #   will be 0 when the plot is not animating and negative when it is.
  # @abstract It does nothing on its own but is provided so that subclasses can
  #   define a custom rendering routine.
  draw: (delta=0) -> super()

  dimensionsChanged: ->
    super()
    @svg.attr('width', @width).attr('height', @height)
    @_sizeCanvas()
    @_buildAxes()
    @draw(@animation.frame * @animation.delta())

  # Updates axes in response to an <code>option:axes</code> event.
  axesChanged: ->
    for pos in ['top', 'right', 'bottom', 'left']
      continue if @options.margins? and @options.margins[pos]?
      if @hasAxis(pos)
        @margins[pos] = defaultAxisMargins[pos]
      else
        @margins[pos] = 6
    @_sizeCanvas()
    @_buildAxes()
    @draw(@animation.frame * @animation.delta())

  # Updates ticks in response to an <code>option.ticks.*</code> event.
  ticksChanged: ->
    @_resetInitialTimeTicks()
    @_transitionRangeAxes()
    @draw(@animation.frame * @animation.delta())

  # Updates tick formats in response to an <code>option.tickFormats.*</code> event.
  tickFormatsChanged: ->
    @_resetInitialTimeTicks()
    @_transitionRangeAxes()
    @draw(@animation.frame * @animation.delta())

  # Updates margins in response to an <code>option.margins.*</code> event.
  marginsChanged: ->
    return unless @options.margins?
    for own pos, size of @options.margins
      unless size?
        @margins[pos] = 6
      else
        @margins[pos] = size

    @_sizeCanvas()
    @draw(@animation.frame * @animation.delta())

  layerChanged: ->
    @_transitionRangeAxes()
    super()


# Base class for all "stacked" plot types (e.g. bar charts, area charts, etc.)
# @abstract It does not perform rendering but instead formats the data
#   so as to ease the process of rendering stacked plots.
class Epoch.Time.Stack extends Epoch.Time.Plot
  # Sets stacking information (y0) for each of the points in each layer
  _stackLayers: ->
    return unless (layers = @getVisibleLayers()).length > 0
    for i in [0...layers[0].values.length]
      y0 = 0
      for layer in layers
        layer.values[i].y0 = y0
        y0 += layer.values[i].y

  # Adds stacking information for layers entering the visualization.
  # @param [Array] layers Layers to stack.
  _prepareLayers: (layers) ->
    y0 = 0
    for own i, d of layers
      continue unless @data[i].visible
      d.y0 = y0
      y0 += d.y
    return layers

  # Ensures that elements are stacked when setting the initial data.
  # @param [Array] data Layered data to set for the visualization.
  setData: (data) ->
    super(data)
    @_stackLayers()

  # Finds the correct extent to use for range axes (left and right).
  # @return [Array] An extent array with the first element equal to 0
  #   and the second element equal to the maximum value amongst the
  #   stacked entries.
  extent: ->
    [max, layers] = [0, @getVisibleLayers()]
    return [0, 0] unless layers.length

    for i in [0...layers[0].values.length]
      sum = 0
      for j in [0...layers.length]
        sum += layers[j].values[i].y
      max = sum if sum > max

    [0, max]

  layerChanged: ->
    @_stackLayers()
    @_prepareLayers(layers) for layers in @_queue
    super()
