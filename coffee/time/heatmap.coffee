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

    #console.log @data

    # Create the paint canvas
    @paint = $("<canvas width='#{(@options.windowSize + 2)*@w()}' height='#{@height}'>").get(0)
    @p = @paint.getContext('2d')
    @_paintCol = 0

  _paintEntry: (entry) ->
    # TODO IMplement me (uses @_paintCol)

  # Distributes the full histogram in the entry into the defined buckets
  # for the visualization.
  _prepareEntry: (entry) ->
    prepared = { time: entry.time, max: 0, buckets: {} }
    [min, max] = @options.bucketRange
    size = (max - min) / @options.buckets

    #console.log entry.histogram

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

  h: ->
    @innerHeight() / @options.buckets

  _offsetX: ->
    0.5*@w()

  # Prepares initially set data for rendering (see _makeBuckets() above)
  setData: (data) ->
    super(data)
    for layer in @data
      layer.values = layer.values.map((entry) => @_prepareEntry(entry))

  _avgRgb: (entries, bucket) ->
    [r, g, b, total] = [0, 0, 0, 0]
    for entry in entries
      continue unless entry.buckets[bucket]?
      total += entry.buckets[bucket]

    for i, entry of entries
      if entry.buckets[bucket]?
        value = entry.buckets[bucket]|0
      else
        value = 0
      ratio = value / total
      color = d3.rgb(entry.color)

      r += ratio * color.r
      g += ratio * color.g
      b += ratio * color.b
    d3.rgb(r, g, b).toString()

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
    
    [w, h, trans] = [@w(), @h(), @inTransition()]

    [i, k] = [@options.windowSize, @data[0].values.length]
    while (--i >= -2) && (--k >= 0)
      entries = []
      bucketTotals = {}
      maxTotal = 0

      for layer in @data
        entry = layer.values[k]
        for bucket, count of entry.buckets
          bucketTotals[bucket] ?= 0
          bucketTotals[bucket] += count
        maxTotal += entry.max
        styles = @getStyles ".#{layer.className.split(' ').join('.')} rect.bucket"
        entry.color = styles.fill
        entries.push entry

      xPos = i * w + delta + (if trans then w else 0)
      j = @options.buckets
      for bucket, sum of bucketTotals
        color = @_avgLab(entries, bucket)
        max = 0
        for entry in entries
          max += (entry.buckets[bucket] / sum) * maxTotal
        @ctx.fillStyle = Epoch.toRGBA(color, @_colorFn(sum, max))
        @ctx.fillRect xPos, (j-1) * h, w-@options.bucketPadding, h-@options.bucketPadding
        j--


        


# "Audio... Audio... Audio... Video Disco..." - Justice