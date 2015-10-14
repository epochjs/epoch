
# Real-time Heatmap Implementation.
class Epoch.Time.Heatmap extends Epoch.Time.Plot
  defaults =
    type: 'time.heatmap'
    buckets: 10
    bucketRange: [0, 100]
    opacity: 'linear'
    bucketPadding: 2
    paintZeroValues: false
    cutOutliers: false

  # Easy to use "named" color functions
  colorFunctions =
    root: (value, max) -> Math.pow(value/max, 0.5)
    linear: (value, max) -> value / max
    quadratic: (value, max) -> Math.pow(value/max, 2)
    cubic: (value, max) -> Math.pow(value/max, 3)
    quartic: (value, max) -> Math.pow(value/max, 4)
    quintic: (value, max) -> Math.pow(value/max, 5)

  optionListeners =
    'option:buckets': 'bucketsChanged'
    'option:bucketRange': 'bucketRangeChanged'
    'option:opacity': 'opacityChanged'
    'option:bucketPadding': 'bucketPaddingChanged'
    'option:paintZeroValues': 'paintZeroValuesChanged'
    'option:cutOutliers': 'cutOutliersChanged'

  # Creates a new heatmap.
  # @param [Object] options Options for the heatmap.
  # @option options [Integer] buckets Number of vertical buckets to use when normalizing the
  #   incoming histogram data for visualization in the heatmap (default: 10).
  # @option options [Array] bucketRange A range of acceptable values to be bucketed (default: [0, 100]).
  # @option options [String, Function] opacity The opacity coloring function to use when rendering buckets
  #   in a column. The built-in functions (referenced by string) are: 'root', 'linear', 'quadratic', 'cubic',
  #   'quartic', and 'quintic'. A custom function can be supplied given it accepts two parameters (value, max)
  #   and returns a numeric value from 0 to 1. Default: linear.
  # @option options [Number] bucketPadding Amount of padding to apply around buckets (default: 2).
  constructor: (@options={}) ->
    super(@options = Epoch.Util.defaults(@options, defaults))
    @_setOpacityFunction()
    @_setupPaintCanvas()
    @onAll optionListeners
    @draw()

  _setOpacityFunction: ->
    if Epoch.isString(@options.opacity)
      @_opacityFn = colorFunctions[@options.opacity]
      Epoch.exception "Unknown coloring function provided '#{@options.opacity}'" unless @_opacityFn?
    else if Epoch.isFunction(@options.opacity)
      @_opacityFn = @options.opacity
    else
      Epoch.exception "Unknown type for provided coloring function."

  # Prepares initially set data for rendering.
  # @param [Array] data Layered histogram data for the visualization.
  setData: (data) ->
    super(data)
    for layer in @data
      layer.values = layer.values.map((entry) => @_prepareEntry(entry))

  # Distributes the full histogram in the entry into the defined buckets
  # for the visualization.
  # @param [Object] entry Entry to prepare for visualization.
  _getBuckets: (entry) ->
    prepared =
      time: entry.time
      max: 0
      buckets: (0 for i in [0...@options.buckets])

    # Bucket size = (Range[1] - Range[0]) / number of buckets
    bucketSize = (@options.bucketRange[1] - @options.bucketRange[0]) / @options.buckets

    for own value, count of entry.histogram
      index = parseInt((value - @options.bucketRange[0]) / bucketSize)

      # Remove outliers from the preprared buckets if instructed to do so
      if @options.cutOutliers and ((index < 0) or (index >= @options.buckets))
        continue

      # Bound the histogram to the range (aka, handle out of bounds values)
      if index < 0
        index = 0
      else if index >= @options.buckets
        index = @options.buckets - 1

      prepared.buckets[index] += parseInt count

    for i in [0...prepared.buckets.length]
      prepared.max = Math.max(prepared.max, prepared.buckets[i])

    return prepared

  # @return [Function] The y scale for the heatmap.
  y: ->
    d3.scale.linear()
      .domain(@options.bucketRange)
      .range([@innerHeight(), 0])

  # @return [Function] The y scale for the svg portions of the heatmap.
  ySvg: ->
    d3.scale.linear()
      .domain(@options.bucketRange)
      .range([@innerHeight() / @pixelRatio, 0])

  # @return [Number] The height to render each bucket in a column (disregards padding).
  h: ->
    @innerHeight() / @options.buckets

  # @return [Number] The offset needed to center ticks at the middle of each column.
  _offsetX: ->
    0.5 * @w() / @pixelRatio

  # Creates the painting canvas which is used to perform all the actual drawing. The contents
  # of the canvas are then copied into the actual display canvas and through some image copy
  # trickery at the end of a transition the illusion of motion over time is preserved.
  #
  # Using two canvases in this way allows us to render an incredible number of buckets in the
  # visualization and animate them at high frame rates without smashing the cpu.
  _setupPaintCanvas: ->
    # Size the paint canvas to have a couple extra columns so we can perform smooth transitions
    @paintWidth = (@options.windowSize + 1) * @w()
    @paintHeight = @height * @pixelRatio

    # Create the "memory only" canvas and nab the drawing context
    @paint = document.createElement('CANVAS')
    @paint.width = @paintWidth
    @paint.height = @paintHeight
    @p = Epoch.Util.getContext @paint

    # Paint the initial data (rendering backwards from just before the fixed paint position)
    @redraw()

    # Hook into the events to paint the next row after it's been shifted into the data
    @on 'after:shift', '_paintEntry'

    # At the end of a transition we must reset the paint canvas by shifting the viewable
    # buckets to the left (this allows for a fixed cut point and single renders below in @draw)
    @on 'transition:end', '_shiftPaintCanvas'
    @on 'transition:end', => @draw(@animation.frame * @animation.delta())

  # Redraws the entire heatmap for the current data.
  redraw: ->
    return unless Epoch.isNonEmptyArray(@data) and Epoch.isNonEmptyArray(@data[0].values)
    entryIndex = @data[0].values.length
    drawColumn = @options.windowSize

    # This addresses a strange off-by-one issue when the chart is transitioning
    drawColumn++ if @inTransition()

    while (--entryIndex >= 0) and (--drawColumn >= 0)
      @_paintEntry(entryIndex, drawColumn)
    @draw(@animation.frame * @animation.delta())

  # Computes the correct color for a given bucket.
  # @param [Integer] value Normalized value at the bucket.
  # @param [Integer] max Normalized maximum for the column.
  # @param [String] color Computed base color for the bucket.
  _computeColor: (value, max, color) ->
    Epoch.Util.toRGBA(color, @_opacityFn(value, max))

  # Paints a single entry column on the paint canvas at the given column.
  # @param [Integer] entryIndex Index of the entry to paint.
  # @param [Integer] drawColumn Column on the paint canvas to place the visualized entry.
  _paintEntry: (entryIndex=null, drawColumn=null) ->
    [w, h] = [@w(), @h()]

    entryIndex ?= @data[0].values.length - 1
    drawColumn ?= @options.windowSize

    entries = []
    bucketTotals = (0 for i in [0...@options.buckets])
    maxTotal = 0

    for layer in @getVisibleLayers()
      entry = @_getBuckets( layer.values[entryIndex] )
      for own bucket, count of entry.buckets
        bucketTotals[bucket] += count
      maxTotal += entry.max
      styles = @getStyles ".#{layer.className.split(' ').join('.')} rect.bucket"
      entry.color = styles.fill
      entries.push entry

    xPos = drawColumn * w

    @p.clearRect xPos, 0, w, @paintHeight

    j = @options.buckets

    for own bucket, sum of bucketTotals
      color = @_avgLab(entries, bucket)
      max = 0
      for entry in entries
        max += (entry.buckets[bucket] / sum) * maxTotal
      if sum > 0 or @options.paintZeroValues
        @p.fillStyle = @_computeColor(sum, max, color)
        @p.fillRect xPos, (j-1) * h, w-@options.bucketPadding, h-@options.bucketPadding
      j--

  # This shifts the image contents of the paint canvas to the left by 1 column width.
  # It is called after a transition has ended (yay, slight of hand).
  _shiftPaintCanvas: ->
    data = @p.getImageData @w(), 0, @paintWidth-@w(), @paintHeight
    @p.putImageData data, 0, 0

  # Performs an averaging of the colors for muli-layer heatmaps using the lab color space.
  # @param [Array] entries The layers for which the colors are to be averaged.
  # @param [Number] bucket The bucket in the entries that must be averaged.
  # @return [String] The css color code for the average of all the layer colors.
  _avgLab: (entries, bucket) ->
    [l, a, b, total] = [0, 0, 0, 0]
    for entry in entries
      continue unless entry.buckets[bucket]?
      total += entry.buckets[bucket]

    for own i, entry of entries
      if entry.buckets[bucket]?
        value = entry.buckets[bucket]|0
      else
        value = 0
      ratio = value / total
      color = d3.lab(entry.color)
      l += ratio * color.l
      a += ratio * color.a
      b += ratio * color.b

    d3.lab(l, a, b).toString()

  # Copies the paint canvas onto the display canvas, thus rendering the heatmap.
  draw: (delta=0) ->
    @clear()
    @ctx.drawImage @paint, delta, 0
    super()

  # Changes the number of buckets in response to an <code>option:buckets</code> event.
  bucketsChanged: -> @redraw()

  # Changes the range of the buckets in response to an <code>option:bucketRange</code> event.
  bucketRangeChanged: ->
    @_transitionRangeAxes()
    @redraw()

  # Changes the opacity function in response to an <code>option:opacity</code> event.
  opacityChanged: ->
    @_setOpacityFunction()
    @redraw()

  # Changes the bucket padding in response to an <code>option:bucketPadding</code> event.
  bucketPaddingChanged: -> @redraw()

  # Changes whether or not to paint zeros in response to an <code>option:paintZeroValues</code> event.
  paintZeroValuesChanged: -> @redraw()

  # Changes whether or not to cut outliers when bucketing in response to an
  # <code>option:cutOutliers</code> event.
  cutOutliersChanged: -> @redraw()

  layerChanged: -> @redraw()

# "Audio... Audio... Audio... Video Disco..." - Justice
