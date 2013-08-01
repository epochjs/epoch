#
# Real-time Line Chart
#
class Epoch.Time.Line extends Epoch.Time.Plot
  setStyles: (className) ->
    styles = @getStyles "g.#{className.replace(/\s/g,'.')} path.line"
    @ctx.fillStyle = styles.fill
    @ctx.strokeStyle = styles.stroke
    @ctx.lineWidth = styles['stroke-width'].replace('px', '')

  # Draws the lines, yo
  draw: (delta=0) ->
    @clear()
    [y, w] = [@y(), @w()]

    for layer in @data
      continue unless layer.values.length > 0
      @setStyles(layer.className)
      @ctx.beginPath()

      [i, k, trans] = [@options.windowSize, layer.values.length, @inTransition()]
      
      while (--i >= -2) and (--k >= 0)
        entry = layer.values[k]
        args = [(i+1)*w+delta, y(entry.y)]
        args[0] += w if trans
        if i == @options.windowSize - 1
          @ctx.moveTo.apply @ctx, args
        else
          @ctx.lineTo.apply @ctx, args

      @ctx.stroke()
