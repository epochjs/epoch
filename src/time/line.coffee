
# Real-time line chart implementation
class Epoch.Time.Line extends Epoch.Time.Plot
  constructor: (@options={}) ->
    @options.type ?= 'time.line'
    super(@options)
    @draw()

  # Sets the graphics context styles based ont he given layer class name.
  # @param [String] className The class name of the layer for which to set the styles.
  setStyles: (className) ->
    styles = @getStyles "g.#{className.replace(/\s/g,'.')} path.line"
    @ctx.fillStyle = styles.fill
    @ctx.strokeStyle = styles.stroke
    @ctx.lineWidth = @pixelRatio * styles['stroke-width'].replace('px', '')

  # Draws the line chart.
  draw: (delta=0) ->
    @clear()
    w = @w()
    for layer in @getVisibleLayers()
      continue unless Epoch.isNonEmptyArray(layer.values)
      @setStyles(layer.className)
      @ctx.beginPath()
      y = @y(layer.range)
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
