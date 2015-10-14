
# Real-time stacked area chart implementation.
class Epoch.Time.Area extends Epoch.Time.Stack
  constructor: (@options={}) ->
    @options.type ?= 'time.area'
    super(@options)
    @draw()

  # Sets the appropriate styles to the graphics context given a particular layer.
  # @param [Object] layer Layer for which to set the styles.
  setStyles: (layer) ->
    if layer? && layer.className?
      styles = @getStyles "g.#{layer.className.replace(/\s/g,'.')} path.area"
    else
      styles = @getStyles "g path.area"
    @ctx.fillStyle = styles.fill
    if styles.stroke?
      @ctx.strokeStyle = styles.stroke
    if styles['stroke-width']?
      @ctx.lineWidth = styles['stroke-width'].replace('px', '')

  # Draws areas for the chart
  _drawAreas: (delta=0) ->
    [y, w, layers] = [@y(), @w(), @getVisibleLayers()]

    for i in [layers.length-1..0]
      continue unless (layer = layers[i])

      @setStyles layer
      @ctx.beginPath()

      [j, k, trans] = [@options.windowSize, layer.values.length, @inTransition()]
      firstX = null
      while (--j >= -2) and (--k >= 0)
        entry = layer.values[k]
        args = [(j+1)*w+delta, y(entry.y + entry.y0)]
        args[0] += w if trans
        if i == @options.windowSize - 1
          @ctx.moveTo.apply @ctx, args
        else
          @ctx.lineTo.apply @ctx, args

      if trans
        borderX = (j+3)*w+delta
      else
        borderX = (j+2)*w+delta

      @ctx.lineTo(borderX, @innerHeight())
      @ctx.lineTo(@width*@pixelRatio+w+delta, @innerHeight())
      @ctx.closePath()
      @ctx.fill()

  # Draws strokes for the chart
  _drawStrokes: (delta=0) ->
    [y, w, layers] = [@y(), @w(), @getVisibleLayers()]

    for i in [layers.length-1..0]
      continue unless (layer = layers[i])
      @setStyles layer
      @ctx.beginPath()

      [i, k, trans] = [@options.windowSize, layer.values.length, @inTransition()]
      firstX = null
      while (--i >= -2) and (--k >= 0)
        entry = layer.values[k]
        args = [(i+1)*w+delta, y(entry.y + entry.y0)]
        args[0] += w if trans
        if i == @options.windowSize - 1
          @ctx.moveTo.apply @ctx, args
        else
          @ctx.lineTo.apply @ctx, args

      @ctx.stroke()

  # Draws the area chart.
  draw: (delta=0) ->
    @clear()
    @_drawAreas(delta)
    @_drawStrokes(delta)
    super()
