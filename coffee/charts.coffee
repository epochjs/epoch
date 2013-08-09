
# Base class for all two-dimensional d3 charts. This class handles axes and margins
# so that subclasses can focus on the construction of particular chart types.
class Epoch.Chart.Plot extends Epoch.Chart.SVG
  defaults =
    margins:
      top: 25
      right: 50
      bottom: 25
      left: 50
    axes: ['left', 'bottom']
    ticks:
      top: 14
      bottom: 14
      left: 5
      right: 5
    tickFormats:
      top: Epoch.Formats.regular
      bottom: Epoch.Formats.regular
      left: Epoch.Formats.si
      right: Epoch.Formats.si

  # Creates a new plot chart.
  # @param [Object] options Options to use when constructing the plot.
  # @option options [Object] margins For setting explicit values for the top, 
  #   right, bottom, and left margins in the visualization. Normally these can
  #   be omitted and the class will set appropriately sized margins given which
  #   axes are specified.
  # @option options [Array] axes A list of axes to display (top, left, bottom, right).
  # @option options [Object] ticks Number of ticks to place on the top, left bottom
  #   and right axes.
  # @option options [Object] tickFormats What tick formatting functions to use for
  #   the top, bottom, left, and right axes.
  constructor: (@options={}) ->
    givenMargins = Epoch.Util.copy(@options.margins) or {}
    super(@options = Epoch.Util.defaults(@options, defaults))

    # Margins are used in a special way and only for making room for axes.
    # However, a user may explicitly set margins in the options, so we need
    # to determine if they did so, and zero out the ones they didn't if no
    # axis is present.
    @margins = {}
    for pos in ['top', 'right', 'bottom', 'left']
      @margins[pos] = @options.margins[pos]
      @margins[pos] = 6 unless givenMargins[pos]? or @hasAxis(pos)
    
    # Add a translation for the top and left margins
    @svg = @svg.append("g")
      .attr("transform", "translate(#{@margins.left}, #{@margins.top})")

  # Sets the tick formatting function to use on the given axis.
  # @param [String] axis Name of the axis.
  # @param [Function] fn Formatting function to use.
  setTickFormat: (axis, fn) ->
    @options.tickFormats[axis] = fn

  # @return [Boolean] <code>true</code> if the chart has an axis with a given name, <code>false</code> otherwise.
  # @param [String] axis Name of axis to check.
  hasAxis: (axis) ->
    @options.axes.indexOf(axis) > -1

  # @return [Number] Width of the visualization portion of the chart (width - margins).
  innerWidth: ->
    @width - (@margins.left + @margins.right)

  # @return [Number] Height of the visualization portion of the chart (height - margins).
  innerHeight: ->
    @height - (@margins.top + @margins.bottom)

  # @return [Function] The x scale for the visualization.
  x: ->
    d3.scale.linear()
      .domain(@extent((d) -> d.x))
      .range([0, @innerWidth()])

  # @return [Function] The y scale for the visualization.
  y: ->
    d3.scale.linear()
      .domain(@extent((d) -> d.y))
      .range([@innerHeight(), 0])

  # @return [Function] d3 axis to use for the bottom of the visualization.
  bottomAxis: ->
    d3.svg.axis().scale(@x()).orient('bottom')
      .ticks(@options.ticks.bottom)
      .tickFormat(@options.tickFormats.bottom)

  # @return [Function] d3 axis to use for the top of the visualization.
  topAxis: ->
    d3.svg.axis().scale(@x()).orient('top')
      .ticks(@options.ticks.top)
      .tickFormat(@options.tickFormats.top)

  # @return [Function] d3 axis to use on the left of the visualization.
  leftAxis: ->
    d3.svg.axis().scale(@y()).orient('left')
      .ticks(@options.ticks.left)
      .tickFormat(@options.tickFormats.left)

  # @return [Function] d3 axis to use on the right of the visualization.
  rightAxis: ->
    d3.svg.axis().scale(@y()).orient('right')
      .ticks(@options.ticks.right)
      .tickFormat(@options.tickFormats.right)
  
  # Renders the axes for the visualization (subclasses must implement specific
  # drawing routines).
  draw: ->
    super()
    if @_axesDrawn
      @_redrawAxes()
    else
      @_drawAxes()

  # Redraws the axes for the visualization.
  _redrawAxes: ->
    if @hasAxis('bottom')
      @svg.selectAll('.x.axis.bottom').transition()
        .duration(500)
        .ease('linear')
        .call(@bottomAxis())
    if @hasAxis('top')
      @svg.selectAll('.x.axis.top').transition()
        .duration(500)
        .ease('linear')
        .call(@topAxis())
    if @hasAxis('left')
      @svg.selectAll('.y.axis.left').transition()
        .duration(500)
        .ease('linear')
        .call(@leftAxis())
    if @hasAxis('right')
      @svg.selectAll('.y.axis.right').transition()
        .duration(500)
        .ease('linear')
        .call(@rightAxis())

  # Draws the initial axes for the visualization.
  _drawAxes: ->
    if @hasAxis('bottom')
      @svg.append("g")
        .attr("class", "x axis bottom")
        .attr("transform", "translate(0, #{@innerHeight()})")
        .call(@bottomAxis())
    if @hasAxis('top')
      @svg.append("g")
        .attr('class', 'x axis top')
        .call(@topAxis())
    if @hasAxis('left')
      @svg.append("g")
        .attr("class", "y axis left")
        .call(@leftAxis())
    if @hasAxis('right')
      @svg.append('g')
        .attr('class', 'y axis right')
        .attr('transform', "translate(#{@innerWidth()}, 0)")
        .call(@rightAxis())
    @_axesDrawn = true

