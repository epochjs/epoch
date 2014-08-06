class Epoch.Chart.Histogram extends Epoch.Chart.Bar
  defaults =
    domain: [0, 100]
    bucketRange: [0, 100]
    buckets: 10
    cutOutliers: false

  constructor: (@options={}) ->


    super(@options = Epoch.Util.defaults(@options, defaults))

  setData: (data) ->
    bucketSize = (@options.bucketRange[1] - @options.bucketRange[0]) / @options.buckets

    prepared = []
    for layer in data
      buckets = (0 for i in [0...@options.buckets])
      for point in layer.values
        index = parseInt((point.x - @options.bucketRange[0]) / bucketSize)

        if @options.cutOutliers and ((index < 0) or (index >= @options.buckets))
          continue
        if index < 0
          index = 0
        else if index >= @options.buckets
          index = @options.buckets - 1

        buckets[index] += parseInt point.y

      preparedLayer = { values: (buckets.map (d, i) -> {x: parseInt(i) * bucketSize, y: d}) }
      for k, v of layer
        preparedLayer[k] = v unless k == 'values'

      prepared.push preparedLayer

    super(prepared)
