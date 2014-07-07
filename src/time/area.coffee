
# Real-time stacked area chart implementation.
class Epoch.Time.Area extends Epoch.Time.Stack

  # Sets the appropriate styles to the graphics context given a particular layer.
  # @param [Object] layer Layer for which to set the styles.
  setStyles: (layer) ->
    if layer.className?
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
    [y, w] = [@y(), @w()]

    for i in [@data.length-1..0]
      layer = @data[i]
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

      if trans
        borderX = (i+3)*w+delta
      else
        borderX = (i+2)*w+delta

      @ctx.lineTo(borderX, @innerHeight())
      @ctx.lineTo(@width*@pixelRatio+w+delta, @innerHeight())
      @ctx.closePath()
      @ctx.fill()

  # Draws strokes for the chart
  _drawStrokes: (delta=0) ->
    [y, w] = [@y(), @w()]

    for i in [@data.length-1..0]
      layer = @data[i]
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
    return unless @isVisible()
    @clear()
    @_drawAreas(delta)
    @_drawStrokes(delta)
    super()
