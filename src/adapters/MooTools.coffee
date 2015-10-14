MooToolsModule = ->
  # Data key to use for storing a reference to the chart instance on an element.
  DATA_NAME = 'epoch-chart'

  # Adds an Epoch chart of the given type to the referenced element.
  # @param [Object] options Options for the chart.
  # @option options [String] type The type of chart to append to the referenced element.
  # @return [Object] The chart instance that was associated with the containing element.
  Element.implement 'epoch', (options) ->
    self = $$(this)
    unless (chart = self.retrieve(DATA_NAME)[0])?
      options.el = this
      klass = Epoch._typeMap[options.type]
      unless klass?
        Epoch.exception "Unknown chart type '#{options.type}'"
      self.store DATA_NAME, (chart = new klass options)
    return chart

MooToolsModule() if window.MooTools?
