describe 'Epoch.Chart', ->
  [defaultWidth, defaultHeight] = [320, 240]

  describe 'Base', ->
    div1 = null
    div1Width = 800
    div1Height = 200

    before (done) ->
      div1 = doc.createElement('div')
      div1.id = 'base-1'
      doc.body.appendChild(div1)
      d3.select('#base-1').style
        width: "#{div1Width}px"
        height: "#{div1Height}px"
      done()

    after (done) ->
      doc.body.removeChild(div1)
      done()

    describe 'constructor', ->
      it 'should set default dimensions', ->
        c = new Epoch.Chart.Base()
        assert.equal c.width, defaultWidth, 'Did not set default width'
        assert.equal c.height, defaultHeight, 'Did not set default height'

      it 'should allow dimensions to be set via options', ->
        [width, height] = [500, 780]
        c = new Epoch.Chart.Base({ width: width, height: height })
        assert.equal c.width, width, "Did not set width to #{width}"
        assert.equal c.height, height, "Did not set height to #{height}"

      it 'should use the dimensions of the given element when applicable', ->
        c = new Epoch.Chart.Base({ el: '#base-1' })
        assert.equal c.width, div1Width, "Did not set width to that of the div"
        assert.equal c.height, div1Height, "Did not set height to that of the div"

      it 'should set default data to an empty array', ->
        c = new Epoch.Chart.Base()
        assert.isArray c.data
        assert.equal c.data.length, 0

      it 'should set data when given as an option', ->
        data = [
          {label: 'A', values: [{x: 0, y: 0}]}, 
          {label: 'B', values: [{x: 1, y: 1}]}
        ]
        c = new Epoch.Chart.Base({ data: data })
        assert.sameMembers(c.data, data)

    describe 'setData', ->
      data = [
        {label: 'A', values: [{x: 10, y: 20}]},
        {label: 'B', values: [{x: 10, y: 20}]},
        {label: 'C', values: [{x: 10, y: 20}]}
      ]
      classNames = [
        ['layer', 'category1', 'a'],
        ['layer', 'category2', 'b'],
        ['layer', 'category3', 'c']
      ]
      chart = null

      before (done) ->
        (chart = new Epoch.Chart.Base()).setData(data)
        done()

      it 'should set data correctly', ->
        assert.sameMembers chart.data, data
        for i in [0...data.length]
          assert.equal chart.data[i].label, data[i].label
          assert.equal chart.data[i].values[0], data[i].values[0]

      it 'should add the correct categories and class names', ->
        for i in [0...data.length]
          className = chart.data[i].className
          for name in classNames[i]
            assert (className.indexOf(name) > -1), "Missing class '#{name}'"

    describe 'draw', ->
      it "should trigger the 'draw' event", (done) ->
        errorCallback = ->
          assert 'false', "The 'draw' event was never triggered"
          done()
        timeout = setTimeout(errorCallback, 1000)
        chart = new Epoch.Chart.Base()
        chart.on 'draw', ->
          clearTimeout(timeout)
          done()
        chart.draw()

    describe 'update', ->
      it 'should call draw by default', (done) ->
        errorCallback = ->
          assert false, "update did not call draw by default."
          done()
        timeout = setTimeout(errorCallback, 1000)
        chart = new Epoch.Chart.Base()
        chart.on 'draw', ->
          clearTimeout(timeout)
          done()
        chart.update([])

      it 'should not call draw when instructed', (done) ->
        chart = new Epoch.Chart.Base()
        chart.on 'draw', ->
          assert false, "Update incorrectly called draw."
          done()
        chart.update([], false)
        done()

    describe 'extent', ->
      data = [
        {values: [
          {x: -1, y: 10},
          {x: 2, y: 20},
          {x: 4, y: 50},
          {x: 8, y: 9900}
        ]},
        {values: [
          {x: 1, y: 170},
          {x: 7, y: -2380},
          {x: 19, y: 90},
          {x: 33, y: 17}
        ]}
      ]

      [xMin, xMax] = [-1, 33]
      [yMin, yMax] = [-2380, 9900]

      chart = null

      before (done) ->
        chart = new Epoch.Chart.Base({ data: data })
        done()

      it 'should find the correct extent given a y-comparitor', ->
        [min, max] = chart.extent (d) -> d.y
        assert.equal min, yMin, "Incorrect minimum y"
        assert.equal max, yMax, "Incorrect maximum y"

      it 'should find the correct extent give an x-comparitor', ->
        [min, max] = chart.extent (d) -> d.x
        assert.equal min, xMin, "Incorrect minimum x"
        assert.equal max, xMax, "Incorrect maximum x"

    describe 'option', ->
      it 'should return all options for the chart when called with no arguments', ->
        options = { a: 20, b: 30, c: { d: 40 } }
        chart = new Epoch.Chart.Base options
        assert.isObject chart.option()
        assert.deepEqual chart.option(), options

      it 'should return a single value when given a key', ->
        options = { a: 20, b: 30 }
        chart = new Epoch.Chart.Base options
        assert.equal chart.option('a'), options.a
        assert.equal chart.option('b'), options.b
        assert.isUndefined chart.option('c')

      it 'should return a deep value when given a hierarchical key', ->
        options =
          a:
            b: 20
            c:
              d: 30
        chart = new Epoch.Chart.Base options
        assert.equal chart.option('a.b'), options.a.b
        assert.equal chart.option('a.c.d'), options.a.c.d

      it 'should set an option given a string and a value', ->
        chart = new Epoch.Chart.Base()
        [key, value] = ['a', 'hello world']
        chart.option(key, value)
        assert.equal chart.option(key), value

      it 'should set a deep value when given a hierarchical key', ->
        chart = new Epoch.Chart.Base()

        map =
          'a.b': 'deep'
          'a.c.d': 'deeper'
          'b': 'shallow'

        for key, value of map
          chart.option(key, value)
          assert.equal chart.option(key), value

      it 'should set all options given an object', ->
        original = { a: 20, b: { c: 30 } }
        newOptions = { a: 15, d: { e: 10, f: 30 } }
        chart = new Epoch.Chart.Base 
        chart.option(newOptions)
        assert.deepEqual chart.option(), newOptions


  describe 'SVG', ->
    [containerWidth, containerHeight] = [1000, 280]
    container = null

    before (done) ->
      container = doc.createElement('DIV')
      container.id = 'svg-container'
      doc.body.appendChild(container)
      d3.select('#svg-container').style
        'width': "#{containerWidth}px"
        'height': "#{containerHeight}px"
      done()

    after (done) ->
      doc.body.removeChild(container)
      done()

    describe 'constructor', ->
      it 'should create a new SVG when not given an element', ->
        chart = new Epoch.Chart.SVG()
        assert.ok chart.svg, "SVG not created"

      it 'should set the default width and height of the SVG', ->
        chart = new Epoch.Chart.SVG()
        assert.equal chart.svg.attr('width'), defaultWidth, "Default width not set"
        assert.equal chart.svg.attr('height'), defaultHeight, "Default height not set"

      it 'should set custom dimensions for the SVG via options', ->
        [customWidth, customHeight] = [500, 600]
        chart = new Epoch.Chart.SVG({ width: customWidth, height: customHeight })
        assert.equal chart.svg.attr('width'), customWidth, "Custom width not set"
        assert.equal chart.svg.attr('height'), customHeight, "Custom height not set"

      it 'should set the container dimensions for the SVG', ->
        chart = new Epoch.Chart.SVG({ el: '#svg-container' })
        assert.equal chart.svg.attr('width'), containerWidth
        assert.equal chart.svg.attr('height'), containerHeight

  describe 'Canvas', ->
    [containerWidth, containerHeight] = [1000, 280]
    container = null
    container_id = 'canvas-container'
    containedChart = null

    before (done) ->
      container = doc.createElement('DIV')
      container.id = container_id
      doc.body.appendChild(container)
      d3.select('#' + container_id).style
        'width': "#{containerWidth}px"
        'height': "#{containerHeight}px"

      containedChart = new Epoch.Chart.Canvas
        el: '#' + container_id
        pixelRatio: 1

      done()

    after (done) ->
      doc.body.removeChild(container)
      done()

    describe 'constructor', ->
      it 'should correctly detect the pixelRatio', ->
        chart = new Epoch.Chart.Canvas()
        assert.equal chart.pixelRatio, 2

      it 'should allow the pixelRatio to be explicitly overriden', ->
        customPixelRatio = 4.2
        chart = new Epoch.Chart.Canvas({ pixelRatio: customPixelRatio })
        assert.equal chart.pixelRatio, customPixelRatio

      it 'should create a child canvas', ->
        chart = new Epoch.Chart.Canvas()
        assert.ok chart.canvas, "Did not create canvas"
        assert.equal chart.canvas.node().tagName.toLowerCase(), 'canvas', 'Did not create a canvas node'

      it 'should append the child canvas to the containing element', ->
        assert.equal containedChart.canvas.node().parentNode.id, container_id

      it 'should set the default dimensions for the canvas', ->
        chart = new Epoch.Chart.Canvas({ pixelRatio: 1 })
        assert.equal chart.canvas.attr('width'), defaultWidth
        assert.equal chart.canvas.attr('height'), defaultHeight

      it 'should allow custom dimensions for the canvas', ->
        [customWidth, customHeight] = [999, 888]
        chart = new Epoch.Chart.Canvas
          width: customWidth
          height: customHeight
          pixelRatio: 1
        assert.equal chart.canvas.attr('width'), customWidth
        assert.equal chart.canvas.attr('height'), customHeight

      it 'should set container dimensions for the canvas', ->
        assert.equal containedChart.canvas.attr('width'), containerWidth
        assert.equal containedChart.canvas.attr('height'), containerHeight

      it 'should fetch a graphics context from the canvas', ->
        assert.ok containedChart.ctx, "Did not fetch graphics context from canvas"

      it 'should take pixel ratio into account when setting canvas dimension attributes', ->
        pixelRatio = 3
        chart = new Epoch.Chart.Canvas({ pixelRatio: pixelRatio })
        assert.equal chart.canvas.attr('width'), defaultWidth * pixelRatio
        assert.equal chart.canvas.attr('height'), defaultHeight * pixelRatio

      it 'should not take pixel ratio into account when setting canvas dimension styles', ->
        chart = new Epoch.Chart.Canvas({ pixelRatio: 2 })
        assert.equal +chart.canvas.style('width').replace('px', ''), defaultWidth
        assert.equal +chart.canvas.style('height').replace('px', ''), defaultHeight

    describe 'getWidth', ->
      it 'should take pixel ratio into account', ->
        pixelRatio = 2
        chart = new Epoch.Chart.Canvas({ pixelRatio: pixelRatio })
        assert.equal chart.getWidth(), pixelRatio * defaultWidth

    describe 'getHeight', ->
      it 'should take pixel ratio into account', ->
        pixelRatio = 2
        chart = new Epoch.Chart.Canvas({ pixelRatio: pixelRatio })
        assert.equal chart.getHeight(), pixelRatio * defaultHeight

    #describe 'getStyles', ->
