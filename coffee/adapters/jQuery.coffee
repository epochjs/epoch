#
# Epoch jQuery adapter
#
DATA_NAME = 'epoch-chart'

jQuery.fn.epoch = (options) ->
  options.el = @
  unless (chart = @.data(DATA_NAME))?
    klass = Epoch._typeMap[options.type]
    unless klass?
    	Epoch.exception "Unknown chart type '#{options.type}'"
    @.data DATA_NAME, (chart = new klass options)
    chart.draw()
  return chart
