
# Real-time Heatmap Implementation.
class Epoch.Time.Heatmap extends Epoch.Time.Plot
  defaults =
    buckets: 10
    bucketRange: [0, 100]
    opacity: 'linear'
    bucketPadding: 2

  # Easy to use "named" color functions
  colorFunctions =
    root: (value, max) -> Math.pow(value/max, 0.5)
    linear: (value, max) -> value / max
    quadratic: (value, max) -> Math.pow(value/max, 2)
    cubic: (value, max) -> Math.pow(value/max, 3)
    quartic: (value, max) -> Math.pow(value/max, 4)
    quintic: (value, max) -> Math.pow(value/max, 5) 

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
  constructor: (@options) ->
    super(@options = Epoch.Util.defaults(@options, defaults))
    if Epoch.isString(@options.opacity)
      @_colorFn = colorFunctions[@options.opacity]
      Epoch.exception "Unknown coloring function provided '#{@options.opacity}'" unless @_colorFn?
    else if Epoch.isFunction(@options.opacity)
      @_colorFn = @options.opacity
    else
      Epoch.exception "Unknown type for provided coloring function."

    # Create the paint canvas
    @_setupPaintCanvas()

  # Prepares initially set data for rendering.
  # @param [Array] data Layered histogram data for the visualization.
  setData: (data) ->
    super(data)
    for layer in @data
      layer.values = layer.values.map((entry) => @_prepareEntry(entry))

  # Distributes the full histogram in the entry into the defined buckets
  # for the visualization.
  # @param [Object] entry Entry to prepare for visualization.
  _prepareEntry: (entry) ->
    prepared = { time: entry.time, max: 0, buckets: {} }
    [min, max] = @options.bucketRange
    size = (max - min) / @options.buckets

    for i in [0...@options.buckets]
      prepared.buckets[min + size * (i+1)] = 0

    for value, count of entry.histogram
      for i in [0...@options.buckets]
        bucketMax = min + size * (i+1)
        if value < bucketMax or i == (@options.buckets - 1)
          prepared.buckets[bucketMax] += count
          break

    for max, count of prepared.buckets
      prepared.max = Math.max(prepared.max, count)

    return prepared

  # @return [Function] The y scale for the heatmap.
  y: ->
    d3.scale.linear()
      .domain(@options.bucketRange)
      .range([@innerHeight(), 0])

  # @return [Number] The height to render each bucket in a column (disregards padding).
  h: ->
    @innerHeight() / @options.buckets

  # @return [Number] The offset needed to center ticks at the middle of each column.
  _offsetX: ->
    0.5*@w()

  # Creates the painting canvas which is used to perform all the actual drawing. The contents
  # of the canvas are then copied into the actual display canvas and through some image copy
  # trickery at the end of a transition the illusion of motion over time is preserved.
  #
  # Using two canvases in this way allows us to render an incredible number of buckets in the
  # visualization and animate them at high frame rates without smashing the cpu.
  _setupPaintCanvas: ->
    # Size the paint canvas to have a couple extra columns so we can perform smooth transitions
    @paintWidth = (@options.windowSize + 1) * @w()
    @paintHeight = @height

    # Create the "memory only" canvas and nab the drawing context
    @paint = $("<canvas width='#{@paintWidth}' height='#{@paintHeight}'>").get(0)
    @p = @paint.getContext('2d')

    # Paint the initial data (rendering backwards from just before the fixed paint position)
    @redraw()

    # Hook into the events to paint the next row after it's been shifted into the data
    @on 'after:shift', '_paintEntry'

    # At the end of a transition we must reset the paint canvas by shifting the viewable
    # buckets to the left (this allows for a fixed cut point and single renders below in @draw)
    @on 'transition:end', '_shiftPaintCanvas'

  # Redraws the entire heatmap for the current data.
  redraw: ->
    entryIndex = @data[0].values.length
    drawColumn = @options.windowSize
    while (--entryIndex >= 0) and (--drawColumn >= 0)
      @_paintEntry(entryIndex, drawColumn)

  # Paints a single entry column on the paint canvas at the given column.
  # @param [Integer] entryIndex Index of the entry to paint.
  # @param [Integer] drawColumn Column on the paint canvas to place the visualized entry.
  _paintEntry: (entryIndex=null, drawColumn=null) ->
    [w, h] = [@w(), @h()]

    entryIndex ?= @data[0].values.length - 1
    drawColumn ?= @options.windowSize

    entries = []
    bucketTotals = {}
    maxTotal = 0

    for layer in @data
      entry = layer.values[entryIndex]
      for bucket, count of entry.buckets
        bucketTotals[bucket] ?= 0
        bucketTotals[bucket] += count
      maxTotal += entry.max
      styles = @getStyles ".#{layer.className.split(' ').join('.')} rect.bucket"
      entry.color = styles.fill
      entries.push entry

    xPos = drawColumn * w

    @p.clearRect xPos, 0, w, @paintHeight

    j = @options.buckets
    for bucket, sum of bucketTotals
      color = @_avgLab(entries, bucket)
      max = 0
      for entry in entries
        max += (entry.buckets[bucket] / sum) * maxTotal
      @p.fillStyle = Epoch.toRGBA(color, @_colorFn(sum, max))
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

    for i, entry of entries
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

# "Audio... Audio... Audio... Video Disco..." - Justice