#
# Real-time Heatmap
#
class Epoch.Time.Heatmap extends Epoch.Time.Plot
  defaults =
    buckets: 10
    bucketRange: [0, 100]
    color: 'linear'
    margins:
      right: 25

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
      console.log colorFunctions[@options.color]
      Epoch.exception "Unknown coloring function provided '#{@options.color}'" unless @_colorFn?
    else if Epoch.isFunction(@options.color)
      @_colorFn = @options.color
    else
      Epoch.exception "Unknown type for provided coloring function."

  # Distributes the full histogram in the entry into the defined buckets
  # for the visualization.
  _prepareEntry: (entry) ->
    prepared = { time: entry.time, max: 0, buckets: {} }
    [min, max] = @options.bucketRange
    size = (max - min) / @options.buckets

    for value, count of entry.histogram
      for i in [0...@options.buckets]
        bucketMax = min + size * (i+1)
        if value < bucketMax or i == (@options.buckets - 1)
          prepared.buckets[bucketMax] ?= 0
          prepared.buckets[bucketMax] += count
          break

    for max, count of prepared.buckets
      prepared.max = Math.max(prepared.max, count)

    return prepared

  h: ->
    @innerHeight() / @options.buckets

  _offsetX: ->
    0.5*@w()

  # Prepares initially set data for rendering (see _prepareEntry() above)
  setData: (data) ->
    super(data)
    for layer in @data
      layer.values = layer.values.map((entry) => @_prepareEntry(entry))

  draw: (delta=0) ->
    # TODO Real stylez yo
    color = "rgba(190, 25, 25, %)"

    # TODO Draw backwards, yo
    [w, h] = [@w(), @h()]
    for layer in @data
      for i, entry of layer.values
        k = @options.buckets
        for bucket, count of entry.buckets
          @ctx.fillStyle = color.replace('%', @_colorFn(count, entry.max).toFixed(2))
          @ctx.fillRect i * w + delta, (k-1) * h, w-2, h-2
          k--


# "Audio... Audio... Audio... Video Disco..." - Justice