
class Epoch.Model extends Epoch.Events
  defaults =
    dataFormat: null

  constructor: (options={}) ->
    super()
    options = Epoch.Util.defaults options, defaults
    @dataFormat = options.dataFormat
    @data = options.data
    @loading = false

  setData: (data) ->
    @data = data
    @trigger 'data:updated'

  push: (entry) ->
    @entry = entry
    @trigger 'data:push'

  hasData: ->
    @data?

  getData: (type='area', dataFormat) ->
    dataFormat ?= @dataFormat
    Epoch.Data.formatData @data, type, dataFormat

  getNext: (type='time.area', dataFormat) ->
    dataFormat ?= @dataFormat
    Epoch.Data.formatEntry @entry, type, dataFormat

#class Epoch.RealTimeModel extends 

