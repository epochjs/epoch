#
# Epoch jQuery adapter
#

F._typeMap =
  'area': F.Chart.Area
  'bar': F.Chart.Bar
  'line': F.Chart.Line
  'pie': F.Chart.Pie
  'scatter': F.Chart.Scatter
  'time.area': F.Time.Area
  'time.bar': F.Time.Bar
  'time.line': F.Time.Line

DATA_NAME = 'epoch-chart'

jQuery.fn.epoch = (options) ->
  options.el = @
  unless (chart = @.data(DATA_NAME))?
    klass = F._typeMap[options.type]
    unless klass?
      throw "Epoch Error: Unknown chart type '#{options.type}'"  
    @.data DATA_NAME, (chart = new klass options)
    chart.draw()
  return chart
