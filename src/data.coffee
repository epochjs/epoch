Epoch.Data ?= {}
Epoch.Data.Format ?= {}

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
Epoch.Data.Format.array = (->
  defaultOptions =
    x: (d, i) -> i
    y: (d, i) -> d
    time: (d, i, startTime) -> parseInt(startTime) + parseInt(i)
    type: 'area'
    autoLabels: false
    labels: []
    startTime: parseInt(new Date().getTime() / 1000)

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


# Formats an input array of tuples such that the first element of the tuple is set
# as the x-coordinate and the second element as the y-coordinate. Supports layers
# of tupled series. For real-time plots the first element of a tuple is set as the
# time component of the value.
#
# This formatter will return an empty array if the chart <code>type</code> option is
# set as 'time.heatmap', 'time.gauge', or 'pie'.
#
# @param data Data array to format (can be multidimensional to allow for multiple layers).
# @option options [String] type Type of chart for which to format the data.
# @option options [Function] x(d, i) Maps the data to x values given a data point and the index of the point.
# @option options [Function] y(d, i) Maps the data to y values given a data point and the index of the point.
# @option options [Function] time(d, i, startTime) Maps the data to time values for real-time plots given the point and index.
# @option options [Array] labels Labels to apply to each data layer.
# @option options [Boolean] autoLabels Apply labels of ascending capital letters to each layer if true.
Epoch.Data.Format.tuple = (->
  defaultOptions =
    x: (d, i) -> d
    y: (d, i) -> d
    time: (d, i) -> d
    type: 'area'
    autoLabels: false
    labels: []

  buildLayers = (data, options, mapFn) ->
    return [] unless Epoch.isArray(data[0])
    result = []
    if Epoch.isArray(data[0][0])
      for i, series of data
        result.push applyLayerLabel({values: series.map(mapFn)}, options, parseInt(i))
    else
      result.push applyLayerLabel({values: data.map(mapFn)}, options, 0)
    return result

  (data=[], options={}) ->
    return [] unless Epoch.isArray(data) and data.length > 0
    opt = Epoch.Util.defaults options, defaultOptions

    if opt.type == 'pie' or opt.type == 'time.heatmap' or opt.type == 'time.gauge'
      return []
    else if opt.type.match /^time\./
      buildLayers data, opt, (d, i) ->
        {time: opt.time(d[0], parseInt(i)), y: opt.y(d[1], parseInt(i))}
    else
      buildLayers data, opt, (d, i) ->
        {x: opt.x(d[0], parseInt(i)), y: opt.y(d[1], parseInt(i))}
)()


# This formatter expects to be passed a flat array of objects and a list of keys.
# It then extracts the value for each key across each of the objects in the array
# to produce multi-layer plot data of the given chart type. Note that this formatter
# also can be passed an <code>x</code> or <code>time</code> option as a string that
# allows the programmer specify a kto define which key to use for the value of the
# first component of each resulting layer value.
#
# @param [Array] data Flat array of objects to format.
# @param [Array] keys List of keys used to extract data from each of the objects.
# @option options [String] type Type of chart for which to format the data.
# @option options [Function, String] x Either the key to use for the x-componet of
#   the resulting values or a function of the data at that point and index of the data.
# @option options [Functoon, String] time Either an object key or function to use for the
#   time-component of resulting real-time plot values.
# @option options [Array] labels Labels to apply to each data layer.
# @option options [Boolean] autoLabels Apply labels of ascending capital letters to each layer if true.
# @option options [Boolean] keyLabels Apply labels using the keys passed to the formatter.
Epoch.Data.Format.keyvalue = (->
  (data=[], keys=[], options={}) ->
)()


# Convenience data formatting method for easily accessing the various formatters.
# @param [String] formatter Name of the formatter to use.
# @param [Array] data Data to format.
# @param [Object] options Options to pass to the formatter (if any).
Epoch.data = (formatter, data, options={}) ->
  return [] unless (formatFn = Epoch.Data.Format[formatter])?
  formatFn(data, options)
