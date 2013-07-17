#
# Timeseries bar chart
#
class F.Time.Bar extends F.Chart.Canvas
  defaults =
    fps: 20
    windowSize: 45
    margins:
      top: 25
      right: 50
      bottom: 25
      left: 50
    axes: ['bottom']
    ticks:
      top: 5
      bottom: 5
      left: 5
      right: 5
    tickFormats:
      top: F.Formats.seconds
      bottom: F.Formats.seconds
      left: F.Formats.si
      right: F.Formats.si
    #transition:
    #  duration: 1000

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

    # Top and Bottom axis ticks (yucks)
    @_ticks = []
    @_tickOffset = 0

    for i, entry of @data[0].values
      continue unless i % 5 == 4
      @_ticks.push { time: entry.time }

    console.log @options
    console.log @margins
    console.log @_ticks


  # Man I wish we had mixins or something (same as in F.Chart.Plot)

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

  # END "wish we had mixins"

  _prepareEntry: (entry) ->
    y0 = 0
    for i, d of entry
      d.y0 = y0
      y0 += d.y
    return entry

  startTransition: ->
    return if @animation.active == true or @_queue.length == 0
    @_shift()
    @animation.active = true
    @animation.interval = setInterval((=> @animate()), 1000/@options.fps)

  stopTransition: ->
    return unless @inTransition()
    
    # Shift off the end
    time = @data[0].values[0].time
    layer.values.shift() for layer in @data
    if @_ticks[0].time == time
      tick = @_ticks.shift()
      tick.time = @data[0].values[@data[0].values.length-1].time
      @_ticks.push tick

    # Reset the animation frame modulus
    @animation.frame = 0

    # Blarch
    @_tickOffset = (@_tickOffset+1) % 5

    if @_queue.length > 0
      @_shift()
    else
      @animation.active = false
      clearInterval @animation.interval

  inTransition: ->
    @animation.active

  push: (entry) ->
    # Handle entry queue maximum size
    if @_queue.length > @_queueSize
      @_queue.splice @_queueSize, (@_queue.length - @_queueSize)
    return false if @_queue.length == @_queueSize

    # Push the entry into the queue
    @_queue.push @_prepareEntry(entry)

    # Begin the transition unless we are already doing so
    @startTransition() unless @inTransition()

  _shift: ->
    entry = @_queue.shift()
    layer.values.push(entry[i]) for i, layer of @data

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
        args = [ex, y(ey+ey0), w-1.5, @innerHeight()-y(ey)+0.5]
        @ctx.fillRect.apply(@ctx, args)
        @ctx.strokeRect.apply(@ctx, args)

  drawAxes: (delta) ->

    unless @_axesDrawn
      if @hasAxis('left')
        @svg.append("g")
          .attr("class", "y axis left")
          .attr('transform', "translate(#{@margins.left-1}, #{@margins.top})")
          .call(@leftAxis())

      if @hasAxis('right')
        console.log @svg
        @svg.append('g')
          .attr('class', 'y axis right')
          .attr('transform', "translate(#{@width - @margins.right}, #{@margins.top})")
          .call(@rightAxis())


      if @hasAxis('bottom')
        @svg.append('g')
          .attr('class', 'x axis left')
          .attr('transform', "translate(#{@margins.left-1}, #{@innerHeight()})")
          .append('path')
            .attr('class', 'domain')
            .attr('d', "M0,6H#{@innerWidth()+1}")
            
      @_axesDrawn = true

    # Top and bottom axes
    @ctx.save()

    @ctx.translate(0, @innerHeight())

    # RAEL STYLES YO!!!
    @ctx.strokeStyle = '#000'
    @ctx.lineWidth = 1

    # Ticks
    @ctx.save()
    @ctx.translate(delta, 0)

    w = @w()

    @ctx.beginPath()
    for i, tick of @_ticks
      x = w * (i*5 + 0.5 + 4 - @_tickOffset) 
      @ctx.moveTo x, 0
      @ctx.lineTo x, 6
    @ctx.stroke()


    @ctx.textAlign = 'center'
    @ctx.fillStyle = '#000'
    for i, tick of @_ticks
      x = w * (i*5 + 0.5 + 4 - @_tickOffset) 
      @ctx.fillText(@options.tickFormats.bottom(tick.time), x, 16)

    @ctx.restore()

    @ctx.restore()
    

  drawLabels: (delta) ->
    # TODO Implement me

  draw: (delta=0) ->
    @ctx.clearRect(0, 0, @width, @height)
    @drawLayers(delta)
    @drawAxes(delta)
    @drawLabels(delta)





