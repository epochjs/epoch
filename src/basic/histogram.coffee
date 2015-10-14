class Epoch.Chart.Histogram extends Epoch.Chart.Bar
  defaults =
    type: 'histogram'
    domain: [0, 100]
    bucketRange: [0, 100]
    buckets: 10
    cutOutliers: false

  optionListeners =
    'option:bucketRange': 'bucketRangeChanged'
    'option:buckets': 'bucketsChanged'
    'option:cutOutliers': 'cutOutliersChanged'

  constructor: (@options={}) ->
    super(@options = Epoch.Util.defaults(@options, defaults))
    @onAll optionListeners
    @draw()

  # Prepares data by sorting it into histogram buckets as instructed by the chart options.
  # @param [Array] data Data to prepare for rendering.
  # @return [Array] The data prepared to be displayed as a histogram.
  _prepareData: (data) ->
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
      for own k, v of layer
        preparedLayer[k] = v unless k == 'values'

      prepared.push preparedLayer

    return prepared

  # Called when options change, this prepares the raw data for the chart according to the new
  # options, sets it, and renders the chart.
  resetData: ->
    @setData @rawData
    @draw()

  # Updates the chart in response to an <code>option:bucketRange</code> event.
  bucketRangeChanged: -> @resetData()

  # Updates the chart in response to an <code>option:buckets</code> event.
  bucketsChanged: -> @resetData()

  # Updates the chart in response to an <code>option:cutOutliers</code> event.
  cutOutliersChanged: -> @resetData()
