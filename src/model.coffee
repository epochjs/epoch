# Data model for epoch charts. By instantiating a model and passing it to each
# of the charts on a page the application programmer can update data once and
# have each of the charts respond accordingly.
#
# In addition to setting basic / historical data via the setData method, the
# model also supports the push method, which when used will cause real-time
# plots to automatically update and animate.
class Epoch.Model extends Epoch.Events
  defaults =
    dataFormat: null

  # Creates a new Model.
  # @option options dataFormat The default data fromat for the model.
  # @option data Initial data for the model.
  constructor: (options={}) ->
    super()
    options = Epoch.Util.defaults options, defaults
    @dataFormat = options.dataFormat
    @data = options.data
    @loading = false

  # Sets the model's data.
  # @param data Data to set for the model.
  # @event data:updated Instructs listening charts that new data is available.
  setData: (data) ->
    @data = data
    @trigger 'data:updated'

  # Pushes a new entry into the model.
  # @param entry Entry to push.
  # @event data:push Instructs listening charts that a new data entry is available.
  push: (entry) ->
    @entry = entry
    @trigger 'data:push'

  # Determines if the model has data.
  # @return true if the model has data, false otherwise.
  hasData: ->
    @data?

  # Retrieves and formats adata for the specific chart type and data format.
  # @param [String] type Type of the chart for which to fetch the data.
  # @param [String, Object] dataFormat (optional) Used to override the model's default data format.
  # @return The model's data formatted based the parameters.
  getData: (type, dataFormat) ->
    dataFormat ?= @dataFormat
    Epoch.Data.formatData @data, type, dataFormat

  # Retrieves the latest data entry that was pushed into the model.
  # @param [String] type Type of the chart for which to fetch the data.
  # @param [String, Object] dataFormat (optional) Used to override the model's default data format.
  # @return The model's next data entry formatted based the parameters.
  getNext: (type, dataFormat) ->
    dataFormat ?= @dataFormat
    Epoch.Data.formatEntry @entry, type, dataFormat
