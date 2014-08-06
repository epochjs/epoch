Epoch.DataFormat = {}

# Default options for Data Formats
defaultOptions =
  x: (d, i) -> i
  y: (d, i) -> d
  time: (d, i, startTime) -> parseInt(startTime) + parseInt(i)
  type: 'area'
  autoLabels: false
  labels: []
  startTime: parseInt(new Date().getTime() / 1000)

# Private Helper Function for DataFormats below
applyLayerLabel = (layer, options, i) ->
  [labels, autoLabels] = [options.labels, options.autoLabels]
  if labels? and Epoch.isArray(labels) and labels.length > i
    layer.label = labels[i]
  else if autoLabels
    label = []
    while i >= 0
      label.push String.fromCharCode(65+(i%26))
      i -= 26
    layer.label = label.join('')
  return layer

# Formats a given input array for the chart of the specified type. Notes:
#
# * Basic pie charts require a flat array of numbers
# * Real-time histogram charts require sparse histogram objects
#
# @param data Data array to format (can be multidimensional to allow for multiple layers).
# @option options [String] type Type of chart for which to format the data.
# @option options [Function] x(d, i) Maps the data to x values given a data point and the index of the point.
# @option options [Function] y(d, i) Maps the data to y values given a data point and the index of the point.
# @option options [Function] time(d, i, startTime) Maps the data to time values for real-time plots given the point and index.
# @option options [Array] labels Labels to apply to each data layer.
# @option options [Boolean] autoLabels Apply labels of ascending capital letters to each layer if true.
# @option options [Number] startTime Unix timestamp used as the starting point for auto acsending times in 
#   real-time data formatting.
Epoch.DataFormat.array = (->
  buildLayers = (data, options, mapFn) ->
    result = []
    if Epoch.isArray(data[0])
      for i, series of data
        result.push applyLayerLabel({values: series.map(mapFn)}, options, parseInt(i))
    else
      result.push applyLayerLabel({values: data.map(mapFn)}, options, 0)
    return result

  formatBasicPlot = (data, options) ->
    buildLayers data, options, (d, i) ->
      { x: options.x(d, i), y: options.y(d, i) }

  formatTimePlot = (data, options) ->
    buildLayers data, options, (d, i) ->
      { time: options.time(d, i, options.startTime), y: options.y(d, i) }

  formatHeatmap = (data, options) ->
    buildLayers data, options, (d, i) ->
      { time: options.time(d, i, options.startTime), histogram: d }

  formatPie = (data, options) ->
    result = []
    for i, v of data
      return [] unless Epoch.isNumber(data[0])
      result.push applyLayerLabel({ value: v }, options, i)
    return result
        
  (data=[], options={}) ->
    return [] unless Epoch.isArray(data) and data.length > 0
    opt = Epoch.Util.defaults options, defaultOptions

    if opt.type == 'time.heatmap'
      formatHeatmap data, opt
    else if opt.type.match /^time\./
      formatTimePlot data, opt
    else if opt.type == 'pie'
      formatPie data, opt
    else
      formatBasicPlot data, opt
)()
