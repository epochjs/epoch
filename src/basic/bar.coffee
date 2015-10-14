# Static bar chart implementation (using d3).
class Epoch.Chart.Bar extends Epoch.Chart.Plot
  defaults =
    type: 'bar'
    style: 'grouped'
    orientation: 'vertical'
    padding:
      bar: 0.08
      group: 0.1
    outerPadding:
      bar: 0.08
      group: 0.1

  horizontal_specific =
    tickFormats:
      top: Epoch.Formats.si
      bottom: Epoch.Formats.si
      left: Epoch.Formats.regular
      right: Epoch.Formats.regular

  horizontal_defaults = Epoch.Util.defaults(horizontal_specific, defaults)

  optionListeners =
    'option:orientation': 'orientationChanged'
    'option:padding': 'paddingChanged'
    'option:outerPadding': 'paddingChanged'
    'option:padding:bar': 'paddingChanged'
    'option:padding:group': 'paddingChanged'
    'option:outerPadding:bar': 'paddingChanged'
    'option:outerPadding:group': 'paddingChanged'

  constructor: (@options={}) ->
    if @_isHorizontal()
      @options = Epoch.Util.defaults(@options, horizontal_defaults)
    else
      @options = Epoch.Util.defaults(@options, defaults)
    super(@options)
    @onAll optionListeners
    @draw()

  # @return [Boolean] True if the chart is vertical, false otherwise
  _isVertical: ->
    @options.orientation == 'vertical'

  # @return [Boolean] True if the chart is horizontal, false otherwise
  _isHorizontal: ->
    @options.orientation == 'horizontal'

  # @return [Function] The scale used to generate the chart's x scale.
  x: ->
    if @_isVertical()
      d3.scale.ordinal()
        .domain(Epoch.Util.domain(@getVisibleLayers()))
        .rangeRoundBands([0, @innerWidth()], @options.padding.group, @options.outerPadding.group)
    else
      extent = @extent((d) -> d.y)
      extent[0] = Math.min(0, extent[0])
      d3.scale.linear()
        .domain(extent)
        .range([0, @width - @margins.left - @margins.right])

  # @return [Function] The x scale used to render the horizontal bar chart.
  x1: (x0) ->
    d3.scale.ordinal()
      .domain((layer.category for layer in @getVisibleLayers()))
      .rangeRoundBands([0, x0.rangeBand()], @options.padding.bar, @options.outerPadding.bar)

  # @return [Function] The y scale used to render the bar chart.
  y: ->
    if @_isVertical()
      extent = @extent((d) -> d.y)
      extent[0] = Math.min(0, extent[0])
      d3.scale.linear()
        .domain(extent)
        .range([@height - @margins.top - @margins.bottom, 0])
    else
      d3.scale.ordinal()
        .domain(Epoch.Util.domain(@getVisibleLayers()))
        .rangeRoundBands([0, @innerHeight()], @options.padding.group, @options.outerPadding.group)

  # @return [Function] The x scale used to render the vertical bar chart.
  y1: (y0) ->
    d3.scale.ordinal()
      .domain((layer.category for layer in @getVisibleLayers()))
      .rangeRoundBands([0, y0.rangeBand()], @options.padding.bar, @options.outerPadding.bar)

  # Remaps the bar chart data into a form that is easier to display.
  # @return [Array] The reorganized data.
  _remapData: ->
    map = {}
    for layer in @getVisibleLayers()
      className = 'bar ' + layer.className.replace(/\s*layer\s*/, '')
      for entry in layer.values
        map[entry.x] ?= []
        map[entry.x].push { label: layer.category, y: entry.y, className: className }
    ({group: k, values: v} for own k, v of map)

  # Draws the bar char.
  draw: ->
    if @_isVertical()
      @_drawVertical()
    else
      @_drawHorizontal()
    super()

  # Draws the bar chart with a vertical orientation
  _drawVertical: ->
    [x0, y] = [@x(), @y()]
    x1 = @x1(x0)
    height = @height - @margins.top - @margins.bottom
    data = @_remapData()

    # 1) Join
    layer = @g.selectAll(".layer")
      .data(data, (d) -> d.group)

    # 2) Update
    layer.transition().duration(750)
      .attr("transform", (d) -> "translate(#{x0(d.group)}, 0)")

    # 3) Enter / Create
    layer.enter().append("g")
      .attr('class', 'layer')
      .attr("transform", (d) -> "translate(#{x0(d.group)}, 0)")

    rects = layer.selectAll('rect')
      .data((group) -> group.values)

    rects.attr('class', (d) -> d.className)

    rects.transition().duration(600)
      .attr('x', (d) -> x1(d.label))
      .attr('y', (d) -> y(d.y))
      .attr('width', x1.rangeBand())
      .attr('height', (d) -> height - y(d.y))

    rects.enter().append('rect')
      .attr('class', (d) -> d.className)
      .attr('x', (d) -> x1(d.label))
      .attr('y', (d) -> y(d.y))
      .attr('width', x1.rangeBand())
      .attr('height', (d) -> height - y(d.y))

    rects.exit().transition()
      .duration(150)
      .style('opacity', '0')
      .remove()

    # 4) Update new and existing

    # 5) Exit / Remove
    layer.exit()
      .transition()
      .duration(750)
      .style('opacity', '0')
      .remove()

  # Draws the bar chart with a horizontal orientation
  _drawHorizontal: ->
    [x, y0] = [@x(), @y()]
    y1 = @y1(y0)
    width = @width - @margins.left - @margins.right
    data = @_remapData()

    # 1) Join
    layer = @g.selectAll(".layer")
      .data(data, (d) -> d.group)

    # 2) Update
    layer.transition().duration(750)
      .attr("transform", (d) -> "translate(0, #{y0(d.group)})")

    # 3) Enter / Create
    layer.enter().append("g")
      .attr('class', 'layer')
      .attr("transform", (d) -> "translate(0, #{y0(d.group)})")

    rects = layer.selectAll('rect')
      .data((group) -> group.values)

    rects.attr('class', (d) -> d.className)

    rects.transition().duration(600)
      .attr('x', (d) -> 0)
      .attr('y', (d) -> y1(d.label))
      .attr('height', y1.rangeBand())
      .attr('width', (d) -> x(d.y))

    rects.enter().append('rect')
      .attr('class', (d) -> d.className)
      .attr('x', (d) -> 0)
      .attr('y', (d) -> y1(d.label))
      .attr('height', y1.rangeBand())
      .attr('width', (d) -> x(d.y))

    rects.exit().transition()
      .duration(150)
      .style('opacity', '0')
      .remove()

    # 4) Update new and existing

    # 5) Exit / Remove
    layer.exit()
      .transition()
      .duration(750)
      .style('opacity', '0')
      .remove()

  # Generates specific tick marks to emulate d3's linear scale axis ticks
  # for ordinal scales. Note: this should only be called if the user has
  # defined a set number of ticks for a given axis.
  # @param [Number] numTicks Number of ticks to generate
  # @param [String] dataKey Property name of a datum to use for the tick value
  # @return [Array] The ticks for the given axis
  _getTickValues: (numTicks, dataKey='x') ->
    return [] unless @data[0]?
    total = @data[0].values.length
    step = Math.ceil(total / numTicks)|0
    tickValues = (@data[0].values[i].x for i in [0...total] by step)

  # @return [Function] d3 axis to use for the bottom of the visualization.
  bottomAxis: ->
    axis = d3.svg.axis().scale(@x()).orient('bottom')
      .ticks(@options.ticks.bottom)
      .tickFormat(@options.tickFormats.bottom)
    if @_isVertical() and @options.ticks.bottom?
      axis.tickValues @_getTickValues(@options.ticks.bottom)
    axis

  # @return [Function] d3 axis to use for the top of the visualization.
  topAxis: ->
    axis = d3.svg.axis().scale(@x()).orient('top')
      .ticks(@options.ticks.top)
      .tickFormat(@options.tickFormats.top)
    if @_isVertical() and @options.ticks.top?
      axis.tickValues @_getTickValues(@options.ticks.top)
    axis

  # @return [Function] d3 axis to use on the left of the visualization.
  leftAxis: ->
    axis = d3.svg.axis().scale(@y()).orient('left')
      .ticks(@options.ticks.left)
      .tickFormat(@options.tickFormats.left)
    if @_isHorizontal() and @options.ticks.left?
      axis.tickValues @_getTickValues(@options.ticks.left)
    axis

  # @return [Function] d3 axis to use on the right of the visualization.
  rightAxis: ->
    axis = d3.svg.axis().scale(@y()).orient('right')
      .ticks(@options.ticks.right)
      .tickFormat(@options.tickFormats.right)
    if @_isHorizontal() and @options.ticks.right?
      axis.tickValues @_getTickValues(@options.ticks.right)
    axis

  # Updates orientation in response <code>option:orientation</code>.
  orientationChanged: ->
    top = @options.tickFormats.top
    bottom = @options.tickFormats.bottom
    left = @options.tickFormats.left
    right = @options.tickFormats.right

    @options.tickFormats.left = top
    @options.tickFormats.right = bottom
    @options.tickFormats.top = left
    @options.tickFormats.bottom = right

    @draw()

  # Updates padding in response to <code>option:padding:*</code> and <code>option:outerPadding:*</code>.
  paddingChanged: -> @draw()
