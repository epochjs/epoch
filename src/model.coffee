
class Epoch.Model extends Epoch.Events
  defaults =
    dataFormat: null

  constructor: (options={}) ->
    super()
    options = Epoch.Util.defaults options, defaults
    @dataFormat = options.dataFormat
    @data = null
    @loading = false

  setData: (data) ->
    @data = data
    @trigger 'data:updated'

  hasData: ->
    @data?

  getData: (type='area', dataFormat) ->
    dataFormat ?= @dataFormat
    Epoch.Data.formatData @data, type, dataFormat

#class Epoch.RealTimeModel extends 

