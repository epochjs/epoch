#
# Epoch jQuery adapter
#

Epoch._typeMap =
  'area': Epoch.Chart.Area
  'bar': Epoch.Chart.Bar
  'line': Epoch.Chart.Line
  'pie': Epoch.Chart.Pie
  'scatter': Epoch.Chart.Scatter
  'time.area': Epoch.Time.Area
  'time.bar': Epoch.Time.Bar
  'time.line': Epoch.Time.Line

DATA_NAME = 'epoch-chart'

jQuery.fn.epoch = (options) ->
  options.el = @
  unless (chart = @.data(DATA_NAME))?
    klass = Epoch._typeMap[options.type]
    unless klass?
      throw "Epoch Error: Unknown chart type '#{options.type}'"  
    @.data DATA_NAME, (chart = new klass options)
    chart.draw()
  return chart
