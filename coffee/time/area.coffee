#
# Real-time area chart
#
class Epoch.Time.Area extends Epoch.Time.Stack
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

  draw: (delta=0) ->
    @clear()
    [y, w] = [@y(), @w()]

    # Draw the areas
    for i in [@data.length-1..0]
      layer = @data[i]
      @setStyles layer
      @ctx.beginPath()
      for i, entry of layer.values
        args = [i*w+delta, y(entry.y + entry.y0)]
        if i == 0
          @ctx.moveTo.apply @ctx, args
        else
          @ctx.lineTo.apply @ctx, args
      @ctx.lineTo(@width+@w(), @innerHeight())
      @ctx.lineTo(-@w(), @innerHeight())
      @ctx.closePath()
      @ctx.fill()

    # TODO Add strokes
