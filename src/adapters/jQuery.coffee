jQueryModule = ($) ->
  # Data key to use for storing a reference to the chart instance on an element.
  DATA_NAME = 'epoch-chart'

  # Adds an Epoch chart of the given type to the referenced element.
  # @param [Object] options Options for the chart.
  # @option options [String] type The type of chart to append to the referenced element.
  # @return [Object] The chart instance that was associated with the containing element.
  $.fn.epoch = (options) ->
    options.el = @get(0)
    unless (chart = @data(DATA_NAME))?
      klass = Epoch._typeMap[options.type]
      unless klass?
        Epoch.exception "Unknown chart type '#{options.type}'"
      @data DATA_NAME, (chart = new klass options)
    return chart

jQueryModule(jQuery) if window.jQuery?
