zeptoModule = ($) ->
  # For mapping charts to selected elements
  DATA_NAME = 'epoch-chart'
  chartMap = {}
  chartId = 0
  next_cid = -> "#{DATA_NAME}-#{++chartId}"

  # Adds an Epoch chart of the given type to the referenced element.
  # @param [Object] options Options for the chart.
  # @option options [String] type The type of chart to append to the referenced element.
  # @return [Object] The chart instance that was associated with the containing element.
  $.extend $.fn,
    epoch: (options) ->
      return chartMap[cid] if (cid = @data(DATA_NAME))?
      options.el = @get(0)

      klass = Epoch._typeMap[options.type]
      unless klass?
        Epoch.exception "Unknown chart type '#{options.type}'"

      @data DATA_NAME, (cid = next_cid())
      chart = new klass options
      chartMap[cid] = chart

      return chart

zeptoModule(Zepto) if window.Zepto?
