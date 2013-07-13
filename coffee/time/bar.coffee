#
# Timeseries bar chart
#
class F.Time.Bar extends F.Chart.Canvas
  defaults =
    fps: 30
    windowSize: 45

  constructor: (@options) ->
    super(@options = F.Util.defaults(@options, defaults))
    @_transitions = []
    @animation = setInterval (=> @animate()), 1000/@options.fps

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
      .range([@height, 0])

  w: ->
    @width / @options.windowSize

  push: (entry) ->
    y0 = 0
    for i, d of entry
      d.y0 = y0
      y0 += d.y
      @data[i].values.push(d)

    console.log "PUSH"

    @_transitions.push {
      delta: -(@w() / @options.fps),
      frame: 0,
      duration: @options.fps,
      complete: => layer.values.shift() for layer in @data
    }

  animate: ->
    return unless @_transitions.length
    t = @_transitions[0]
    if (++t.frame) == t.duration
      @_transitions.shift()
      t.complete()
    else
      @draw(t.frame * t.delta)

  setStyles: (className) ->
    styles = @getStyles('rect', 'bar ' + className)
    @ctx.fillStyle = styles.fill
    @ctx.strokeStyle = styles.stroke
    @ctx.lineWidth = styles['stroke-width'].replace('px', '')

  drawLayers: (delta) ->
    [y, w] = [@y(), @w()]
    @ctx.clearRect(0, 0, @width, @height)
    for layer in @data
      @setStyles(layer.className)
      for i, entry of layer.values
        [ex, ey, ey0] = [i*w+delta, entry.y, entry.y0]
        args = [ex, y(ey+ey0), w-1.5, @height-y(ey)+0.5]
        @ctx.fillRect.apply(@ctx, args)
        @ctx.strokeRect.apply(@ctx, args)

  drawAxes: (delta) ->
    # TODO Implement me

  drawLabels: (delta) ->
    # TODO Implement me

  draw: (delta=0) ->
    @drawLayers(delta)
    @drawAxes(delta)
    @drawLabels(delta)





