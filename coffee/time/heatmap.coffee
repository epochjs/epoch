#
# Real-time Heatmap
#
class Epoch.Time.Heatmap extends Epoch.Time.Plot
  defaults =
    buckets: 10
    bucketRange: [0, 100]
    color: 'linear'
    bucketPadding: 2

  # Easy to use "named" color functions
  colorFunctions =
    root: (value, max) -> Math.pow(value/max, 0.5)
    linear: (value, max) -> value / max
    quadratic: (value, max) -> Math.pow(value/max, 2)
    cubic: (value, max) -> Math.pow(value/max, 3)
    quartic: (value, max) -> Math.pow(value/max, 4)
    quintic: (value, max) -> Math.pow(value/max, 5) 

  constructor: (@options) ->
    super(@options = Epoch.Util.defaults(@options, defaults))
    if Epoch.isString(@options.color)
      @_colorFn = colorFunctions[@options.color]
      Epoch.exception "Unknown coloring function provided '#{@options.color}'" unless @_colorFn?
    else if Epoch.isFunction(@options.color)
      @_colorFn = @options.color
    else
      Epoch.exception "Unknown type for provided coloring function."

    # Create the paint canvas
    @_setupPaintCanvas()

  # Prepares initially set data for rendering (see _makeBuckets() above)
  setData: (data) ->
    super(data)
    for layer in @data
      layer.values = layer.values.map((entry) => @_prepareEntry(entry))

  # Distributes the full histogram in the entry into the defined buckets
  # for the visualization.
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

  y: ->
    d3.scale.linear()
      .domain(@options.bucketRange)
      .range([@innerHeight(), 0])

  h: ->
    @innerHeight() / @options.buckets

  _offsetX: ->
    0.5*@w()

  #
  # Painting and rendering
  #
  _setupPaintCanvas: ->
    # Size the paint canvas to have a couple extra columns so we can perform smooth transitions
    @paintWidth = (@options.windowSize + 1) * @w()
    @paintHeight = @height

    # Create the "memory only" canvas and nab the drawing context
    @paint = $("<canvas width='#{@paintWidth}' height='#{@paintHeight}'>").get(0)
    @p = @paint.getContext('2d')

    # Paint the initial data (rendering backwards from just before the fixed paint position)
    entryIndex = @data[0].values.length
    drawColumn = @options.windowSize
    while (--entryIndex >= 0) and (--drawColumn >= 0)
      @_paintEntry(entryIndex, drawColumn)

    # Hook into the events to paint the next row after it's been shifted into the data
    @on 'after:shift', '_paintEntry'

    # At the end of a transition we must reset the paint canvas by shifting the viewable
    # buckets to the left (this allows for a fixed cut point and single renders below in @draw)
    @on 'transition:end', '_shiftPaintCanvas'

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

  _shiftPaintCanvas: ->
    data = @p.getImageData @w(), 0, @paintWidth-@w(), @paintHeight
    @p.putImageData data, 0, 0

    # TODO Implement the "end of transition shift"

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

  draw: (delta=0) ->
    @clear()
    @ctx.drawImage @paint, delta, 0

# "Audio... Audio... Audio... Video Disco..." - Justice