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
      @setStyles(layer.className)
      @ctx.beginPath()
      for i, entry of layer.values
        args = [i*w+delta, y(entry.y)]
        if i == 0
          @ctx.moveTo.apply @ctx, args
        else
          @ctx.lineTo.apply @ctx, args
      @ctx.stroke()
