
# Real-time Gauge Visualization. Note: Looks best with a 4:3 aspect ratio (w:h)
class Epoch.Time.Gauge extends Epoch.Chart.Canvas
  defaults =
    type: 'time.gauge'
    domain: [0, 1]
    ticks: 10
    tickSize: 5
    tickOffset: 5
    fps: 34
    format: Epoch.Formats.percent

  optionListeners =
    'option:domain': 'domainChanged'
    'option:ticks': 'ticksChanged'
    'option:tickSize': 'tickSizeChanged'
    'option:tickOffset': 'tickOffsetChanged'
    'option:format': 'formatChanged'

  # Creates the new gauge chart.
  # @param [Object] options Options for the gauge chart.
  # @option options [Array] domain The domain to use when rendering values (default: [0, 1]).
  # @option options [Integer] ticks Number of ticks to render (default: 10).
  # @option options [Integer] tickSize The length (in pixels) for each tick (default: 5).
  # @option options [Integer] tickOffset The number of pixels by which to offset ticks from the outer arc (default: 5).
  # @option options [Integer] fps The number of animation frames to render per second (default: 34).
  # @option options [Function] format The formatting function to use when rendering the gauge label
  #   (default: Epoch.Formats.percent).
  constructor: (@options={}) ->
    super(@options = Epoch.Util.defaults(@options, defaults))
    @value = @options.value or 0

    if @options.model
      @options.model.on 'data:push', => @pushFromModel()

    # SVG Labels Overlay
    if @el.style('position') != 'absolute' and @el.style('position') != 'relative'
      @el.style('position', 'relative')

    @svg = @el.insert('svg', ':first-child')
      .attr('width', @width)
      .attr('height', @height)
      .attr('class', 'gauge-labels')

    @svg.style
      'position': 'absolute'
      'z-index': '1'

    @svg.append('g')
      .attr('transform', "translate(#{@textX()}, #{@textY()})")
      .append('text')
        .attr('class', 'value')
        .text(@options.format(@value))

    # Animations
    @animation =
      interval: null
      active: false
      delta: 0
      target: 0

    @_animate = =>
      if Math.abs(@animation.target - @value) < Math.abs(@animation.delta)
        @value = @animation.target
        clearInterval @animation.interval
        @animation.active = false
      else
        @value += @animation.delta

      @svg.select('text.value').text(@options.format(@value))
      @draw()

    @onAll optionListeners
    @draw()

  # Sets the value for the gauge to display and begins animating the guage.
  # @param [Number] value Value to set for the gauge.
  update: (value) ->
    @animation.target = value
    @animation.delta = (value - @value) / @options.fps
    unless @animation.active
      @animation.interval = setInterval @_animate, (1000/@options.fps)
      @animation.active = true

  # Alias for the <code>update()</code> method.
  # @param [Number] value Value to set for the gauge.
  push: (value) ->
    @update value

  # Responds to a model's 'data:push' event.
  pushFromModel: ->
    next = @options.model.getNext(@options.type, @options.dataFormat)
    @update next

  # @return [Number] The radius for the gauge.
  radius: -> @getHeight() / 1.58

  # @return [Number] The center position x-coordinate for the gauge.
  centerX: -> @getWidth() / 2

  # @return [Number] The center position y-coordinate for the gauge.
  centerY: -> 0.68 * @getHeight()

  # @return [Number] The x-coordinate for the gauge text display.
  textX: -> @width / 2

  # @return [Number] The y-coordinate for the gauge text display.
  textY: -> 0.48 * @height

  # @return [Number] The angle to set for the needle given a value within the domain.
  # @param [Number] value Value to translate into a needle angle.
  getAngle: (value) ->
    [a, b] = @options.domain
    ((value - a) / (b - a)) * (Math.PI + 2*Math.PI/8) - Math.PI/2 - Math.PI/8

  # Sets context styles given a particular selector.
  # @param [String] selector The selector to use when setting the styles.
  setStyles: (selector) ->
    styles = @getStyles selector
    @ctx.fillStyle = styles.fill
    @ctx.strokeStyle = styles.stroke
    @ctx.lineWidth = styles['stroke-width'].replace('px', '') if styles['stroke-width']?

  # Draws the gauge.
  draw: ->
    [cx, cy, r] = [@centerX(), @centerY(), @radius()]
    [tickOffset, tickSize] = [@options.tickOffset, @options.tickSize]

    @clear()

    # Draw Ticks
    t = d3.scale.linear()
      .domain([0, @options.ticks])
      .range([ -(9/8)*Math.PI, Math.PI/8 ])

    @setStyles '.epoch .gauge .tick'
    @ctx.beginPath()
    for i in [0..@options.ticks]
      a = t(i)
      [c, s] = [Math.cos(a), Math.sin(a)]

      x1 = c * (r-tickOffset) + cx
      y1 = s * (r-tickOffset) + cy
      x2 = c * (r-tickOffset-tickSize) + cx
      y2 = s * (r-tickOffset-tickSize) + cy

      @ctx.moveTo x1, y1
      @ctx.lineTo x2, y2

    @ctx.stroke()

    # Outer arc
    @setStyles '.epoch .gauge .arc.outer'
    @ctx.beginPath()
    @ctx.arc cx, cy, r, -(9/8)*Math.PI, (1/8)*Math.PI, false
    @ctx.stroke()

    # Inner arc
    @setStyles '.epoch .gauge .arc.inner'
    @ctx.beginPath()
    @ctx.arc cx, cy, r-10, -(9/8)*Math.PI, (1/8)*Math.PI, false
    @ctx.stroke()

    @drawNeedle()

    super()

  # Draws the needle.
  drawNeedle: ->
    [cx, cy, r] = [@centerX(), @centerY(), @radius()]
    ratio = @value / @options.domain[1]

    @setStyles '.epoch .gauge .needle'
    @ctx.beginPath()
    @ctx.save()
    @ctx.translate cx, cy
    @ctx.rotate @getAngle(@value)

    @ctx.moveTo 4 * @pixelRatio, 0
    @ctx.lineTo -4 * @pixelRatio, 0
    @ctx.lineTo -1 * @pixelRatio, 19-r
    @ctx.lineTo 1, 19-r
    @ctx.fill()

    @setStyles '.epoch .gauge .needle-base'
    @ctx.beginPath()
    @ctx.arc 0, 0, (@getWidth() / 25), 0, 2*Math.PI
    @ctx.fill()

    @ctx.restore()

  # Correctly responds to an <code>option:</code>
  domainChanged: -> @draw()

  # Correctly responds to an <code>option:</code>
  ticksChanged: -> @draw()

  # Correctly responds to an <code>option:</code>
  tickSizeChanged: -> @draw()

  # Correctly responds to an <code>option:</code>
  tickOffsetChanged: -> @draw()

  # Correctly responds to an <code>option:</code>
  formatChanged: -> @svg.select('text.value').text(@options.format(@value))



# "The mother of a million sons... CIVILIZATION!" -- Justice
