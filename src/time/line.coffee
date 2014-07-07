
# Real-time line chart implementation
class Epoch.Time.Line extends Epoch.Time.Plot
  # Sets the graphics context styles based ont he given layer class name.
  # @param [String] className The class name of the layer for which to set the styles.
  setStyles: (className) ->
    styles = @getStyles "g.#{className.replace(/\s/g,'.')} path.line"
    @ctx.fillStyle = styles.fill
    @ctx.strokeStyle = styles.stroke
    @ctx.lineWidth = @pixelRatio * styles['stroke-width'].replace('px', '')

  y: ->
    d3.scale.linear()
      .domain(@extent((d) -> d.y))
      .range([@innerHeight() - @pixelRatio/2, @pixelRatio])

  # Draws the line chart.
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

    super()
