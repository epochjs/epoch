#
# Timeseries bar chart
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
# and readible rendering code that also performs well (hopes... dreams)
#


class F.Time.Bar extends F.Chart.Canvas
  defaults =
    fps: 24
    windowSize: 45
    margins:
      top: 25
      right: 50
      bottom: 25
      left: 50
    axes: ['bottom']
    ticks:
      top: 5
      bottom: 10
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
    

  hasAxis: (name) ->
    @options.axes.indexOf(name) > -1

  innerWidth: ->
    @width - (@margins.left + @margins.right)

  innerHeight: ->
    @height - (@margins.top + @margins.bottom)

  leftAxis: ->
    d3.svg.axis().scale(@y()).orient('left')
      .ticks(@options.ticks.left)
      .tickFormat(@options.tickFormats.left)

  rightAxis: ->
    d3.svg.axis().scale(@y()).orient('right')
      .ticks(@options.ticks.right)
      .tickFormat(@options.tickFormats.right)

  _prepareEntry: (entry) ->
    y0 = 0
    for i, d of entry
      d.y0 = y0
      y0 += d.y
    return entry

  # If there are entries in the incoming data queue this will shift them
  # into the graph's working set and begin animating the scroll transition.
  startTransition: ->
    return if @animation.active == true or @_queue.length == 0
    @_shift()
    @animation.active = true
    @animation.interval = setInterval((=> @animate()), 1000/@options.fps)

  # Stops animating and clears the animation interval given there is no more
  # incoming data to process. Also finalizes tick entering and exiting.
  stopTransition: ->
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
  # the graph.
  push: (entry) ->
    # Handle entry queue maximum size
    if @_queue.length > @_queueSize
      @_queue.splice @_queueSize, (@_queue.length - @_queueSize)
    return false if @_queue.length == @_queueSize

    # Push the entry into the queue
    @_queue.push @_prepareEntry(entry)

    # Begin the transition unless we are already doing so
    @startTransition() unless @inTransition()


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
        .call(@leftAxis())

    if @hasAxis('right')
      @svg.selectAll('.y.axis.right').transition()
        .duration(500)
        .ease('linear')
        .call(@rightAxis())

  animate: ->
    return unless @inTransition()
    @stopTransition() if ++@animation.frame == @animation.duration
    @draw(@animation.frame * @animation.delta)

  setData: (data) ->
    super(data)
    for i in [0...@data[0].values.length]
      y0 = 0
      for layer in @data
        layer.values[i].y0 = y0
        y0 += layer.values[i].y

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

  w: ->
    @innerWidth() / @options.windowSize

  setStyles: (className) ->
    styles = @getStyles('rect', 'bar ' + className)
    @ctx.fillStyle = styles.fill
    @ctx.strokeStyle = styles.stroke
    @ctx.lineWidth = styles['stroke-width'].replace('px', '')

  drawLayers: (delta) ->
    [y, w] = [@y(), @w()]
    for layer in @data
      @setStyles(layer.className)
      for i, entry of layer.values
        [ex, ey, ey0] = [i*w+delta, entry.y, entry.y0]
        args = [ex+1, y(ey+ey0), w-2, @innerHeight()-y(ey)+0.5]
        @ctx.fillRect.apply(@ctx, args)
        @ctx.strokeRect.apply(@ctx, args)


  # This is called every time we introduce new data (as a result of _shift)
  # it checks to see if we also need to update the working tick set and
  # makes the approriate changes for handling tick animation (enter, exit, 
  # and update in the d3 model).
  _updateTicks: (newTime) ->
    # Incoming ticks
    unless (++@_tickTimer) % @options.ticks.bottom
      @_pushTick(@options.windowSize, newTime, true)

    # Outgoing ticks
    unless @_ticks[0].x - @w() >= 0
      @_ticks[0].exit = true

  # Prepares bottom and top time axes for rendering
  _prepareTimeAxes: ->
    if @hasAxis('bottom')
      axis = @bottomAxis = @svg.append('g')
        .attr('class', 'x axis bottom canvas')
        .attr('transform', "translate(#{@margins.left-1}, #{@innerHeight()+@margins.top})")
      axis.append('path')
        .attr('class', 'domain')
        .attr('d', "M0,0H#{@innerWidth()+1}")
      
    [@_ticks, tickInterval] = [[], @options.ticks.bottom]
    @_tickTimer = @options.windowSize % tickInterval
    for i, entry of @data[0].values
      continue unless i % tickInterval == tickInterval - 1
      @_pushTick(i, entry.time)

  # Makes and pushes a new tick into the visualization
  _pushTick: (bucket, time, enter=false) ->
    tick =
      time: time
      label: @options.tickFormats.bottom(time)
      x: bucket*@w() + 0.5*@w()
      opacity: if enter then 0 else 1
      enter: if enter then true else false
      exit: false

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

    tick.el = $(g[0])

    @_ticks.push tick
    return tick

  _shiftTick: ->
    tick = @_ticks.shift()
    tick.el.remove()
    tick.el = null
      
  _updateTimeAxes: ->
    [dx, dop] = [@animation.delta, 1 / @options.fps]
    for tick in @_ticks
      tick.x += dx
      tick.el.attr('transform', "translate(#{tick.x+1},0)")
      if tick.enter
        tick.opacity += dop
        tick.el.css('opacity', tick.opacity)
      else if tick.exit
        tick.opacity -= dop
        tick.el.css('opacity', tick.opacity)

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
     
  draw: (delta=0) ->
    @ctx.clearRect(0, 0, @width, @height)
    @drawLayers(delta)
    @_updateTimeAxes()




