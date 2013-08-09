#
# Real-time Bar Chart
#
class Epoch.Time.Bar extends Epoch.Time.Stack
  # Defines an offset for ticks and markers
  _offsetX: ->
   0.5*@w()

  setStyles: (className) ->
    styles = @getStyles "rect.bar.#{className.replace(/\s/g,'.')}"
    @ctx.fillStyle = styles.fill
    
    if !styles.stroke? or styles.stroke == 'none'
      @ctx.strokeStyle = 'transparent'
    else
      @ctx.strokeStyle = styles.stroke

    if styles['stroke-width']?
      @ctx.lineWidth = styles['stroke-width'].replace('px', '')

  # Draws the stacked bars in the visualization canvas
  draw: (delta=0) ->
    @clear()
    [y, w] = [@y(), @w()]

    for layer in @data
      continue unless layer.values.length > 0
      @setStyles(layer.className)

      [i, k, trans] = [@options.windowSize, layer.values.length, @inTransition()]
      iBoundry = if trans then -1 else 0

      while (--i >= iBoundry) and (--k >= 0)
        entry = layer.values[k]
        [ex, ey, ey0] = [i*w+delta, entry.y, entry.y0]
        ex += w if trans
        args = [ex+1, y(ey+ey0), w-2, @innerHeight()-y(ey)+0.5]
        @ctx.fillRect.apply(@ctx, args)
        @ctx.strokeRect.apply(@ctx, args)
