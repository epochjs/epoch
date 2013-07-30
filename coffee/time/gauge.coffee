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

  constructor: (@options={}) ->
    super(@options = Epoch.Util.defaults(@options, defaults))
    @value = @options.value
    @lastValue = @value

  theta: ->
    d3.scale.linear()
      .domain(@options.domain)
      .range([-(9/8)*Math.PI, Math.PI/8])

  setStyles: (selector) ->
    styles = @getStyles selector
    @ctx.fillStyle = styles.fill
    @ctx.strokeStyle = styles.stroke
    @ctx.lineWidth = styles['stroke-width'].replace('px', '')

  draw: ->
    @ctx.clearRect(0, 0, @width, @height)
    [cx, cy, r] = [@width / 2, 0.68 * @height, @height / 1.58]

    # Draw Ticks
    t = d3.scale.linear()
      .domain([0, @options.ticks])
      .range([ -(9/8)*Math.PI, Math.PI/8 ])

    @setStyles '.epoch .gauge .tick'
    @ctx.beginPath()
    for i in [0..@options.ticks]
      a = t(i)
      [c, s] = [Math.cos(a), Math.sin(a)]

      x1 = c * (r-@options.tickOffset) + cx
      y1 = s * (r-@options.tickOffset) + cy
      x2 = c * (r-@options.tickOffset-@options.tickSize) + cx
      y2 = s * (r-@options.tickOffset-@options.tickSize) + cy

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

    


