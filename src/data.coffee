Epoch.Data ?= {}
Epoch.Data.Format ?= {}

# Private Helper Function for data formats below
applyLayerLabel = (layer, options, i, keys=[]) ->
  [labels, autoLabels, keyLabels] = [options.labels, options.autoLabels, options.keyLabels]
  if labels? and Epoch.isArray(labels) and labels.length > i
    layer.label = labels[i]
  else if keyLabels and keys.length > i
    layer.label = keys[i]
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
      for own i, series of data
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
    for own i, v of data
      return [] unless Epoch.isNumber(data[0])
      result.push applyLayerLabel({ value: v }, options, i)
    return result

  format = (data=[], options={}) ->
    return [] unless Epoch.isNonEmptyArray(data)
    opt = Epoch.Util.defaults options, defaultOptions

    if opt.type == 'time.heatmap'
      formatHeatmap data, opt
    else if opt.type.match /^time\./
      formatTimePlot data, opt
    else if opt.type == 'pie'
      formatPie data, opt
    else
      formatBasicPlot data, opt

  format.entry = (datum, options={}) ->
    if options.type == 'time.gauge'
      return 0 unless datum?
      opt = Epoch.Util.defaults options, defaultOptions
      d = if Epoch.isArray(datum) then datum[0] else datum
      return opt.y(d, 0)

    return [] unless datum?
    unless options.startTime?
      options.startTime = parseInt(new Date().getTime() / 1000)

    if Epoch.isArray(datum)
      data = datum.map (d) -> [d]
    else
      data = [datum]

    (layer.values[0] for layer in format(data, options))

  return format
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
      for own i, series of data
        result.push applyLayerLabel({values: series.map(mapFn)}, options, parseInt(i))
    else
      result.push applyLayerLabel({values: data.map(mapFn)}, options, 0)
    return result

  format = (data=[], options={}) ->
    return [] unless Epoch.isNonEmptyArray(data)
    opt = Epoch.Util.defaults options, defaultOptions

    if opt.type == 'pie' or opt.type == 'time.heatmap' or opt.type == 'time.gauge'
      return []
    else if opt.type.match /^time\./
      buildLayers data, opt, (d, i) ->
        {time: opt.time(d[0], parseInt(i)), y: opt.y(d[1], parseInt(i))}
    else
      buildLayers data, opt, (d, i) ->
        {x: opt.x(d[0], parseInt(i)), y: opt.y(d[1], parseInt(i))}

  format.entry = (datum, options={}) ->
    return [] unless datum?
    unless options.startTime?
      options.startTime = parseInt(new Date().getTime() / 1000)

    if Epoch.isArray(datum) and Epoch.isArray(datum[0])
      data = datum.map (d) -> [d]
    else
      data = [datum]

    (layer.values[0] for layer in format(data, options))

  return format
)()

# This formatter expects to be passed a flat array of objects and a list of keys.
# It then extracts the value for each key across each of the objects in the array
# to produce multi-layer plot data of the given chart type. Note that this formatter
# also can be passed an <code>x</code> or <code>time</code> option as a string that
# allows the programmer specify a key to use for the value of the first component
# (x or time) of each resulting layer value.
#
# Note that this format does not work with basic pie charts nor real-time gauge charts.
#
# @param [Array] data Flat array of objects to format.
# @param [Array] keys List of keys used to extract data from each of the objects.
# @option options [String] type Type of chart for which to format the data.
# @option options [Function, String] x Either the key to use for the x-componet of
#   the resulting values or a function of the data at that point and index of the data.
# @option options [Function, String] time Either an object key or function to use for the
#   time-component of resulting real-time plot values.
# @option options [Function] y(d, i) Maps the data to y values given a data point and the index of the point.
# @option options [Array] labels Labels to apply to each data layer.
# @option options [Boolean] autoLabels Apply labels of ascending capital letters to each layer if true.
# @option options [Boolean] keyLabels Apply labels using the keys passed to the formatter (defaults to true).
# @option options [Number] startTime Unix timestamp used as the starting point for auto acsending times in
#   real-time data formatting.
Epoch.Data.Format.keyvalue = (->
  defaultOptions =
    type: 'area',
    x: (d, i) -> parseInt(i)
    y: (d, i) -> d
    time: (d, i, startTime) -> parseInt(startTime) + parseInt(i)
    labels: []
    autoLabels: false
    keyLabels: true
    startTime: parseInt(new Date().getTime() / 1000)

  buildLayers = (data, keys, options, mapFn) ->
    result = []
    for own j, key of keys
      values = []
      for own i, d of data
        values.push mapFn(d, key, parseInt(i))
      result.push applyLayerLabel({ values: values }, options, parseInt(j), keys)
    return result

  formatBasicPlot = (data, keys, options) ->
    buildLayers data, keys, options, (d, key, i) ->
      if Epoch.isString(options.x)
        x = d[options.x]
      else
        x = options.x(d, parseInt(i))
      { x: x, y: options.y(d[key], parseInt(i)) }

  formatTimePlot = (data, keys, options, rangeName='y') ->
    buildLayers data, keys, options, (d, key, i) ->
      if Epoch.isString(options.time)
        value = { time: d[options.time] }
      else
        value = { time: options.time(d, parseInt(i), options.startTime) }
      value[rangeName] = options.y(d[key], parseInt(i))
      value

  format = (data=[], keys=[], options={}) ->
    return [] unless Epoch.isNonEmptyArray(data) and Epoch.isNonEmptyArray(keys)
    opt = Epoch.Util.defaults options, defaultOptions

    if opt.type == 'pie' or opt.type == 'time.gauge'
      return []
    else if opt.type == 'time.heatmap'
      formatTimePlot data, keys, opt, 'histogram'
    else if opt.type.match /^time\./
      formatTimePlot data, keys, opt
    else
      formatBasicPlot data, keys, opt

  format.entry = (datum, keys=[], options={}) ->
    return [] unless datum? and Epoch.isNonEmptyArray(keys)
    unless options.startTime?
     options.startTime = parseInt(new Date().getTime() / 1000)
    (layer.values[0] for layer in format([datum], keys, options))

  return format
)()

# Convenience data formatting method for easily accessing the various formatters.
# @param [String] formatter Name of the formatter to use.
# @param [Array] data Data to format.
# @param [Object] options Options to pass to the formatter (if any).
Epoch.data = (formatter, args...) ->
  return [] unless (formatFn = Epoch.Data.Format[formatter])?
  formatFn.apply formatFn, args


# Method used by charts and models for handling option based data formatting.
# Abstracted here because we'd like to allow models and indivisual charts to
# perform this action depending on the context.
Epoch.Data.formatData = (data=[], type, dataFormat) ->
  return data unless Epoch.isNonEmptyArray(data)

  if Epoch.isString(dataFormat)
    opts = { type: type }
    return Epoch.data(dataFormat, data, opts)

  return data unless Epoch.isObject(dataFormat)
  return data unless dataFormat.name? and Epoch.isString(dataFormat.name)
  return data unless Epoch.Data.Format[dataFormat.name]?

  args = [dataFormat.name, data]
  if dataFormat.arguments? and Epoch.isArray(dataFormat.arguments)
    args.push(a) for a in dataFormat.arguments

  if dataFormat.options?
    opts = dataFormat.options
    if type?
      opts.type ?= type
    args.push opts
  else if type?
    args.push {type: type}

  Epoch.data.apply(Epoch.data, args)

# Method used to format incoming entries for real-time charts.
Epoch.Data.formatEntry = (datum, type, format) ->
  return datum unless format?

  if Epoch.isString(format)
    opts = { type: type }
    return Epoch.Data.Format[format].entry datum, opts

  return datum unless Epoch.isObject(format)
  return datum unless format.name? and Epoch.isString(format.name)
  return datum unless Epoch.Data.Format[format.name]?

  dataFormat = Epoch.Util.defaults format, {}

  args = [datum]
  if dataFormat.arguments? and Epoch.isArray(dataFormat.arguments)
    args.push(a) for a in dataFormat.arguments

  if dataFormat.options?
    opts = dataFormat.options
    opts.type = type
    args.push opts
  else if type?
    args.push {type: type}

  entry = Epoch.Data.Format[dataFormat.name].entry
  entry.apply entry, args
