#
# Real-time Gauge Visualization
# Note: Looks best with a 4:3 aspect ratio (w:h)
#
class Epoch.Time.Gauge extends Epoch.Chart.Canvas
  defaults =
    domain: [0, 1]
    ticks: 10
    tickSize: 5
    tickOffset: 5
    fps: 34

  constructor: (@options={}) ->
    super(@options = Epoch.Util.defaults(@options, defaults))
    @value = @options.value or 0

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
      @draw()

  # TODO "update" or "push"? Also needs to be correctly implemented with tweening
  update: (value) ->
    @animation.target = value
    @animation.delta = (value - @value) / @options.fps
    unless @animation.active
      @animation.interval = setInterval @_animate, (1000/@options.fps)

  radius: -> @height / 1.58
  centerX: -> @width / 2
  centerY: -> 0.68 * @height

  # TODO Fix me, doesn't work with the first part of the domain
  getAngle: (value) ->
    (value / @options.domain[1]) * (Math.PI + 2*Math.PI/8) - Math.PI/2 - Math.PI/8

  setStyles: (selector) ->
    styles = @getStyles selector
    @ctx.fillStyle = styles.fill
    @ctx.strokeStyle = styles.stroke
    @ctx.lineWidth = styles['stroke-width'].replace('px', '') if styles['stroke-width']?

  draw: ->
    [cx, cy, r] = [@centerX(), @centerY(), @radius()]
    [tickOffset, tickSize] = [@options.tickOffset, @options.tickSize]

    @ctx.clearRect(0, 0, @width, @height)
    
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

  drawNeedle: ->
    [cx, cy, r] = [@centerX(), @centerY(), @radius()]
    ratio = @value / @options.domain[1]

    @setStyles '.epoch .gauge .needle'
    @ctx.beginPath()
    @ctx.save()
    @ctx.translate cx, cy
    @ctx.rotate @getAngle(@value)

    @ctx.moveTo 4, 0
    @ctx.lineTo -4, 0
    @ctx.lineTo -1, 19-r
    @ctx.lineTo 1, 19-r
    @ctx.fill()

    @setStyles '.epoch .gauge .needle-base'
    @ctx.beginPath()
    @ctx.arc 0, 0, (@width / 25), 0, 2*Math.PI
    @ctx.fill()

    @ctx.restore()

