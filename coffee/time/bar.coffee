#
# Real-time Bar Chart
#
class F.Time.Bar extends F.Time.Stack
  # Defines an offset for ticks and markers
  _offsetX: ->
   0.5*@w()

  setStyles: (className) ->
    styles = @getStyles "rect.bar.#{className.replace(/\s/g,'.')}"
    @ctx.fillStyle = styles.fill
    @ctx.strokeStyle = styles.stroke
    if styles['stroke-width']?
      @ctx.lineWidth = styles['stroke-width'].replace('px', '')

  # Draws the stacked bars in the visualization canvas
  draw: (delta=0) ->
    @clear()
    [y, w] = [@y(), @w()]
    for layer in @data
      @setStyles(layer.className)
      for i, entry of layer.values
        [ex, ey, ey0] = [i*w+delta, entry.y, entry.y0]
        args = [ex+1, y(ey+ey0), w-2, @innerHeight()-y(ey)+0.5]
        @ctx.fillRect.apply(@ctx, args)
        @ctx.strokeRect.apply(@ctx, args)

