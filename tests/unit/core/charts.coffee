sinon = require 'sinon'

describe 'Epoch.Chart', ->
  [defaultWidth, defaultHeight] = [320, 240]

  describe 'Base', ->
    [testDivWidth, testDivHeight] = [800, 200]
    [resizeDivWidth, resizeDivHeight] = [200, 200]

    before (done) ->
      d3.select(doc.body).append('div').attr('id', 'testDiv').style
        width: "#{testDivWidth}px"
        height: "#{testDivHeight}px"

      d3.select(doc.body).append('div').attr('id', 'resizeDiv').style
        width: "#{resizeDivWidth}px"
        height: "#{resizeDivHeight}px"

      done()

    after (done) ->
      d3.select('#testDiv').remove()
      d3.select('#resizeDiv').remove()
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
        c = new Epoch.Chart.Base({ el: '#testDiv' })
        assert.equal c.width, testDivWidth, "Did not set width to that of the div"
        assert.equal c.height, testDivHeight, "Did not set height to that of the div"

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
        chart = new Epoch.Chart.Base()
        chart.option(newOptions)
        assert.deepEqual chart.option(), newOptions

      it 'should trigger an event when an option is changed', (done) ->
        [key, value] = ['a', 20]
        eventName = "option:#{key}"

        errorCallback = ->
          assert false, "Setting an option did not trigger the appropriate event: #{eventName}"
          done()
        timeout = setTimeout(errorCallback, 1000)

        chart = new Epoch.Chart.Base()
        chart.on eventName, ->
          clearTimeout(timeout)
          done()
        chart.option(key, value)

      it 'should resize the containing element when the width option is changed', ->
        newWidth = resizeDivWidth + 20
        chart = new Epoch.Chart.Base({ el: '#resizeDiv' })
        chart.option('width', newWidth)
        assert.equal d3.select('#resizeDiv').width(), newWidth

      it 'should resize the containing element when the height option is changed', ->
        newHeight = resizeDivHeight + 20
        chart = new Epoch.Chart.Base({ el: '#resizeDiv' })
        chart.option('height', newHeight)
        assert.equal d3.select('#resizeDiv').height(), newHeight

    describe '_getScaleDomain', ->
      chart = null

      beforeEach ->
        chart = new Epoch.Chart.Base
          data: [ layerWithRange(-2030, 5050) ]

      it 'returns a given array', ->
        assert.deepEqual(chart._getScaleDomain([0,1]), [0,1])

      it 'returns @options.range if it is an array', ->
        chart.options.range = [-100, 100]
        assert.equal chart._getScaleDomain(), chart.options.range

      it 'returns @options.range.left if it is an array', ->
        chart.options.range = {left: [-100, 100]}
        assert.equal chart._getScaleDomain(), chart.options.range.left

      it 'returns @options.range.right if it is an array', ->
        chart.options.range = {right: [-100, 100]}
        assert.equal chart._getScaleDomain(), chart.options.range.right

      it 'returns the extent of the data', ->
        assert.deepEqual chart._getScaleDomain(), chart.extent((d) -> d.y)

      describe 'with range grouped layers', ->
        beforeEach ->
          chart = new Epoch.Chart.Base
            data: [
              layerWithRange(0, 10, 'left'),
              layerWithRange(-5000, 5000, 'right'),
              layerWithRange(-10, -5, 'left')
            ]

        it 'returns the extent of the layers with the given range label', ->
          assert.deepEqual chart._getScaleDomain('left'), [-10, 10]

        it 'returns the extent of the data if the label is invalid', ->
          assert.deepEqual chart._getScaleDomain('foobar'), chart.extent((d) -> d.y)

    describe 'layers', ->
      [chart, eventChart] = [null, null]
      labels = ['A', 'B', 'C']
      data = [
        { label: 'A', data: [{x: 0, y: 0}] },
        { label: 'B', data: [{x: 1, y: 1}] },
        { label: 'C', data: [{x: 2, y: 2}] }
      ]
      data2 = [
        { label: 'A', data: [{x: 0, y: 0}] }
      ]

      before (done) ->
        chart = new Epoch.Chart.Base
          el: doc.createElement('div')
          data: data
        eventChart = new Epoch.Chart.Base
          el: doc.createElement('div')
          data: data2
        done()

      describe '_findLayer', ->
        it 'should find layers given a label', ->
          for label in labels
            layer = chart._findLayer(label)
            assert.equal label, layer.label, "Could not find layer with label #{label}"

        it 'should find layers given an index', ->
          for i in [0...data.length]
            layer = chart._findLayer(i)
            assert.equal labels[i], layer.label, "Could not find layer with index #{i}"

        it 'should return null if given an invalid label', ->
          assert.isNull (chart._findLayer 'D')
          assert.isNull (chart._findLayer 'not a thing')

        it 'should return null if given an index that is out of bounds', ->
          assert.isNull (chart._findLayer -1)
          assert.isNull (chart._findLayer 5)

      describe 'hideLayer', ->
        it 'should hide a visible layer', ->
          chart.hideLayer('A')
          assert.isFalse chart._findLayer('A').visible

        it 'should keep a hidden layer hidden', ->
          assert.isFalse chart._findLayer('A').visible
          chart.hideLayer('A')
          assert.isFalse chart._findLayer('A').visible

        it 'should trigger layer:hidden when a layer is hidden', (done) ->
          errorCallback = ->
            assert false, "layer:hidden was not triggered"
            done()
          timeout = setTimeout errorCallback, 1000
          eventChart.on 'layer:hidden', ->
            clearTimeout timeout
            done()
          eventChart.hideLayer('A')

      describe 'showLayer', ->
        it 'should have keep a visible layer visible', ->
          assert.isTrue chart._findLayer('B').visible
          chart.showLayer('B')
          assert.isTrue chart._findLayer('B').visible

        it 'should make a hidden layer visible', ->
          assert.isFalse chart._findLayer('A').visible
          chart.showLayer('A')
          assert.isTrue chart._findLayer('A').visible

        it 'should trigger layer:shown when a layer is shown', (done) ->
          errorCallback = ->
            assert false, "layer:shown was not triggered"
            done()
          timeout = setTimeout errorCallback, 1000
          eventChart.on 'layer:shown', ->
            clearTimeout timeout
            done()
          eventChart.showLayer('A')

      describe 'toggleLayer', ->
        it 'should hide a visible layer', ->
          chart.hideLayer('A')
          chart.toggleLayer('A')
          assert.isTrue chart._findLayer('A').visible

        it 'should show a hidden layer', ->
          chart.showLayer('B')
          chart.toggleLayer('B')
          assert.isFalse chart._findLayer('B').visible

      describe 'isLayerVisible', ->
        it 'should report true if a layer is visible', ->
          chart.showLayer('A')
          assert.isTrue chart.isLayerVisible('A')

        it 'should report false if a layer is not visible', ->
          chart.hideLayer('A')
          assert.isFalse chart.isLayerVisible('B')

      describe 'getVisibleLayers', ->
        it 'should only return visible layers', ->
          chart.showLayer('A')
          chart.showLayer('B')
          chart.hideLayer('C')
          visible = chart.getVisibleLayers()
          assert.equal visible.length, 2
          assert.equal visible[0].label, 'A'
          assert.equal visible[1].label, 'B'

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

    describe 'dimensionsChanged', ->
      [width, height, chart] = [200, 100, null]

      before (done) ->
        d3.select(doc.body).append('div').attr('id', 'svgResize').style
          width: width + 'px'
          height: height + 'px'
        chart = new Epoch.Chart.SVG { el: '#svgResize' }
        done()

      after (done) ->
        d3.select('#svgResize').remove()
        done()

      it 'should resize the SVG element when the width option is changed', ->
        newWidth = width + 500
        chart.option 'width', newWidth
        assert.equal chart.svg.attr('width'), newWidth

      it 'should resize the SVG element when the height option is changed', ->
        newHeight = height + 500
        chart.option 'height', newHeight
        assert.equal chart.svg.attr('height'), newHeight

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

    describe 'dimensionsChanged', ->
      [width, height, chart, pixelRatio] = [200, 100, null, 2]

      before (done) ->
        d3.select(doc.body).append('div').attr('id', 'canvasResize').style
          width: width + 'px'
          height: height + 'px'
        chart = new Epoch.Chart.Canvas { el: '#canvasResize', pixelRatio: pixelRatio }
        done()

      after (done) ->
        d3.select('#canvasResize').remove()
        done()

      it 'should resize the canvas element when the width option is changed', ->
        newWidth = width + 500
        chart.option 'width', newWidth
        assert.equal chart.canvas.attr('width'), pixelRatio * newWidth
        assert.equal chart.canvas.width(), newWidth

      it 'should resize the canvas element when the height option is changed', ->
        newHeight = height + 500
        chart.option 'height', newHeight
        assert.equal chart.canvas.attr('height'), pixelRatio * newHeight
        assert.equal chart.canvas.height(), newHeight

    describe 'redraw', ->
      chart = null
      drawSpy = null
      purgeSpy = null

      before ->
        chart = new Epoch.Chart.Canvas()

      beforeEach ->
        drawSpy = sinon.spy chart, 'draw'
        purgeSpy = sinon.spy Epoch.QueryCSS, 'purge'

      afterEach ->
        chart.draw.restore()
        Epoch.QueryCSS.purge.restore()

      it 'should purge QueryCSS cache and redraw the canvas based chart with new styles', ->
        chart.redraw()

        assert drawSpy.calledOnce
        assert purgeSpy.calledOnce
