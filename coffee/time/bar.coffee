#
# Timeseries Plot Base Class (used for bar, line, etc.)
#
# Some notes about all this crazy:
#
# So we have to "reimplement" some of the d3 stuff here because of the
# demands it is putting on the cpu when doing normal SVG rendering 
# and transitions.
#
# My theory is that d3 was designed for long period (and mostly user 
# initiated) transitions. Using these assumptions it was made to be as
# general and as expressive as possible (kudos Bostock, et. al.) but
# at the expense of time cost optimization.
#
# In my testing if we move/exit/enter using the traditional model
# core usage will jump considerably, which is unacceptable for
# an all day, erry day, kind of dashboard with many concurrent 
# visualizations.
#
# Thus we reimplement the animation and graph rendering using canvases
# and piggy back on the graphics card. This has the result of drastically
# reducing the load on yonder CPU.
#
# I swear to god that one of these days I will learn how to write elegant
# and readible rendering code that also performs well (hopes... dreams...)
#
class F.Time.Plot extends F.Chart.Canvas
  defaults =
    fps: 24
    windowSize: 20
    margins:
      top: 25
      right: 50
      bottom: 25
      left: 50
    axes: ['bottom']
    ticks:
      time: 15
      left: 5
      right: 5
    tickFormats:
      top: F.Formats.seconds
      bottom: F.Formats.seconds
      left: F.Formats.si
      right: F.Formats.si

  constructor: (@options) ->
    givenMargins = F.Util.copy(@options.margins) or {}
    super(@options = F.Util.defaults(@options, defaults))

    # Queue entering data to get around memory bloat and "non-active" tab issues
    @_queueSize = 10
    @_queue = []

    # Margins
    @margins = {}
    for pos in ['top', 'right', 'bottom', 'left']
      @margins[pos] = @options.margins[pos]
      @margins[pos] = 6 unless givenMargins[pos]? or @hasAxis(pos)

    # SVG Overlay
    @svg = d3.select(@el.get(0)).insert('svg', ':first-child')
      .attr('width', @width)
      .attr('height', @height)

    # Position the canvas "under" the SVG element
    if @el.css('position') != 'absolute' and @el.css('position') != 'relative'
      @el.css('position', 'relative')

    @canvas.attr('width', @innerWidth())
    @canvas.attr('height', @innerHeight() + @margins.bottom)
    @canvas.css
      position: 'absolute'
      top: "#{@margins.top}px"
      left: "#{@margins.left}px"
      'z-index': '-1'
      
    # Animation / Transitions
    @animation =
      interval: null
      active: false
      delta: -(@w() / @options.fps),
      frame: 0,
      duration: @options.fps

    # Top and Bottom axis ticks
    @_prepareTimeAxes()
    @_prepareRangeAxes()

    # Callback used for animation
    @animationCallback = => @_animate()

  # Provides a way to offset ticks
  _offsetX: -> 0

  # Prepares bottom and top time axes for rendering
  _prepareTimeAxes: ->
    if @hasAxis('bottom')
      axis = @bottomAxis = @svg.append('g')
        .attr('class', "x axis bottom canvas")
        .attr('transform', "translate(#{@margins.left-1}, #{@innerHeight()+@margins.top})")
      axis.append('path')
        .attr('class', 'domain')
        .attr('d', "M0,0H#{@innerWidth()+1}")

    if @hasAxis('top')
      axis = @topAxis = @svg.append('g')
        .attr('class', "x axis top canvas")
        .attr('transform', "translate(#{@margins.left-1}, #{@margins.top})")
      axis.append('path')
        .attr('class', 'domain')
        .attr('d', "M0,0H#{@innerWidth()+1}")

    tickInterval = @options.ticks.time
    @_ticks = []
    @_tickTimer = @options.windowSize % tickInterval

    i = tickInterval
    while i < @options.windowSize
      @_pushTick(i, @data[0].values[i].time)
      i += tickInterval  

  # Builds and prepares the range axes (left and right)
  _prepareRangeAxes: ->
    if @hasAxis('left')
      @svg.append("g")
        .attr("class", "y axis left")
        .attr('transform', "translate(#{@margins.left-1}, #{@margins.top})")
        .call(@_leftAxis())

    if @hasAxis('right')
      @svg.append('g')
        .attr('class', 'y axis right')
        .attr('transform', "translate(#{@width - @margins.right}, #{@margins.top})")
        .call(@_rightAxis())

  # @return The d3 left axis
  _leftAxis: ->
    d3.svg.axis().scale(@y()).orient('left')
      .ticks(@options.ticks.left)
      .tickFormat(@options.tickFormats.left)

  # @return The d3 right axis
  _rightAxis: ->
    d3.svg.axis().scale(@y()).orient('right')
      .ticks(@options.ticks.right)
      .tickFormat(@options.tickFormats.right)

  # @param name Name of the axis
  # @return true if the axis was set in the options, false otherwise.
  hasAxis: (name) ->
    @options.axes.indexOf(name) > -1

  # @return The width of the canvas minus the axes margins
  innerWidth: ->
    @width - (@margins.left + @margins.right)

  # @return The height of the canvas minus the axes margins
  innerHeight: ->
    @height - (@margins.top + @margins.bottom)

  
  # Abstract method for performing any preprocessing before queuing new entries
  # @paran entry The entry to prepare
  _prepareEntry: (entry) -> entry
    
  # If there are entries in the incoming data queue this will shift them
  # into the graph's working set and begin animating the scroll transition.
  _startTransition: ->
    return if @animation.active == true or @_queue.length == 0
    @_shift()
    @animation.active = true
    @animation.interval = setInterval(@animationCallback, 1000/@options.fps)

  # Stops animating and clears the animation interval given there is no more
  # incoming data to process. Also finalizes tick entering and exiting.
  _stopTransition: ->
    return unless @inTransition()
    
    # Shift data off the end
    layer.values.shift() for layer in @data

    # Finalize tick transitions
    [firstTick, lastTick] = [@_ticks[0], @_ticks[@_ticks.length-1]]

    if lastTick.enter
      lastTick.enter = false
      lastTick.opacity = 1

    if firstTick.exit
      @_shiftTick()

    # Reset the animation frame modulus
    @animation.frame = 0

    # Clear the transition interval unless another entry is already queued
    if @_queue.length > 0
      @_shift()
    else
      @animation.active = false
      clearInterval @animation.interval

  # True if we are transitioning (scrolling), false otherwise
  inTransition: ->
    @animation.active

  # This is used by the application programmer to push new data into
  # the window of the visualization. Incoming data is not immediately
  # added to the graph but instead added to a fixed size queue so we can
  # get around some browser weirdness (and memory bloat). Finally if we're
  # good to go it will will begin the process of scrolling (or transitioning)
  # the graph (see _shift below).
  push: (entry) ->
    # Handle entry queue maximum size
    if @_queue.length > @_queueSize
      @_queue.splice @_queueSize, (@_queue.length - @_queueSize)
    return false if @_queue.length == @_queueSize

    # Push the entry into the queue
    @_queue.push @_prepareEntry(entry)

    # Begin the transition unless we are already doing so
    @_startTransition() unless @inTransition()


  # Shift elements off the incoming data queue (see the implementation of 
  # push above).
  #
  # If there's data to be shoved into the visualization it will pull it 
  # off the queue and put it into the working dataset. It also calls through
  # to @_updateTicks to handle horizontal (or "time") axes tick transitions
  # since we're implementing independent of d3 as well.
  _shift: ->
    entry = @_queue.shift()
    layer.values.push(entry[i]) for i, layer of @data

    @_updateTicks(entry[0].time)

    if @hasAxis('left')
      @svg.selectAll('.y.axis.left').transition()
        .duration(500)
        .ease('linear')
        .call(@_leftAxis())

    if @hasAxis('right')
      @svg.selectAll('.y.axis.right').transition()
        .duration(500)
        .ease('linear')
        .call(@_rightAxis())

  # Performs the animation for transitioning elements into the visualization
  _animate: ->
    return unless @inTransition()
    @_stopTransition() if ++@animation.frame == @animation.duration
    @draw(@animation.frame * @animation.delta)
    @_updateTimeAxes()

  # @return The y scale for the graph
  y: ->
    d3.scale.linear()
      .domain(@extent((d) -> d.y))
      .range([@innerHeight(), 0])

  # @return The width of a single section of the graph pretaining to a data point
  w: ->
    @innerWidth() / @options.windowSize

  # This is called every time we introduce new data (as a result of _shift)
  # it checks to see if we also need to update the working tick set and
  # makes the approriate changes for handling tick animation (enter, exit, 
  # and update in the d3 model).
  # 
  # @param newTime Current newest timestamp in the data
  _updateTicks: (newTime) ->
    # Incoming ticks
    unless (++@_tickTimer) % @options.ticks.time
      @_pushTick(@options.windowSize, newTime, true)

    # Outgoing ticks
    unless @_ticks[0].x - @w() >= 0
      @_ticks[0].exit = true

  # Makes and pushes a new tick into the visualization
  # @param bucket Index in the data window where the tick should initially be position
  # @param time The unix timestamp associated with the tick
  # @param enter Whether or not the tick should be considered as "newly entering"
  #        Used primarily for performing the tick opacity tween.
  _pushTick: (bucket, time, enter=false) ->
    return unless @hasAxis('top') or @hasAxis('bottom')
    tick =
      time: time
      label: @options.tickFormats.bottom(time)
      x: bucket*@w() + @_offsetX()
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
        .text(tick.label)

      tick.bottomEl = $(g[0])

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
        .text(tick.label)

      tick.topEl = $(g[0])      

    @_ticks.push tick
    return tick

  # Shifts a tick that is no longer needed out of the visualization.
  _shiftTick: ->
    tick = @_ticks.shift()
    for k in ['topEl', 'bottomEl']
      tick[k].remove()
      delete tick[k]
  
  # This performs animations for the time axes (top and bottom)
  _updateTimeAxes: ->
    return unless @hasAxis('top') or @hasAxis('bottom')
    [dx, dop] = [@animation.delta, 1 / @options.fps]

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
        tick.bottomEl.css('opacity', tick.opacity) if @hasAxis('bottom')
        tick.topEl.css('opacity', tick.opacity) if @hasAxis('top')
  
  # Abstract method to be overriden in subclasses for performing specific graph drawing
  # @param frame Animation frame (zero unless the graph is scrolling)
  draw: (frame=0)->



#
# Real-time Bar Chart
#
class F.Time.Bar extends F.Time.Plot
  # Defines an offset for ticks and markers
  _offsetX: ->
   0.5*@w()

  # Make sure to use sum over the timestamp for the max
  y: ->
    max = 0
    for i in [0...@data[0].values.length]
      sum = 0
      for j in [0...@data.length]
        sum += @data[j].values[i].y
      max = sum if sum > max

    d3.scale.linear()
      .domain([0, max])
      .range([@innerHeight(), 0])

  # Stacks incoming entries into the visualization
  _prepareEntry: (entry) ->
    y0 = 0
    for i, d of entry
      d.y0 = y0
      y0 += d.y
    return entry

  # Stacks the entries after directly setting the data
  setData: (data) ->
    super(data)
    for i in [0...@data[0].values.length]
      y0 = 0
      for layer in @data
        layer.values[i].y0 = y0
        y0 += layer.values[i].y

  # Handles the setting of styles on the graphics context for
  # our particular type of graph (the stacked bar char ;)
  setStyles: (className) ->
    styles = @getStyles('rect', 'bar ' + className)
    @ctx.fillStyle = styles.fill
    @ctx.strokeStyle = styles.stroke
    @ctx.lineWidth = styles['stroke-width'].replace('px', '')

  # Draws the stacked bars in the visualization canvas
  draw: (delta=0) ->
    @ctx.clearRect(0, 0, @innerWidth(), @innerHeight())
    [y, w] = [@y(), @w()]
    for layer in @data
      @setStyles(layer.className)
      for i, entry of layer.values
        [ex, ey, ey0] = [i*w+delta, entry.y, entry.y0]
        args = [ex+1, y(ey+ey0), w-2, @innerHeight()-y(ey)+0.5]
        @ctx.fillRect.apply(@ctx, args)
        @ctx.strokeRect.apply(@ctx, args)

#
# Real-time Line Chart
#
class F.Time.Line extends F.Time.Plot
  # setStyles: (className) ->
  #   styles = @getStyles('g', className + ' path')
  #   console.log styles
  #   @ctx.fillStyle = styles.fill
  #   @ctx.strokeStyle = styles.stroke
  #   @ctx.lineWidth = styles['stroke-width'].replace('px', '')

  # Draws the lines, yo
  draw: (delta=0) ->
    @ctx.clearRect(0, 0, @innerWidth(), @innerHeight())
    [y, w] = [@y(), @w()]
    for layer in @data
      #@setStyles(layer.className)
      @ctx.beginPath()
      for i, entry of layer.values
        args = [i*w+delta, y(entry.y)]
        if i == 0
          @ctx.moveTo.apply @ctx, args
        else
          @ctx.lineTo.apply @ctx, args
      @ctx.stroke()

  




