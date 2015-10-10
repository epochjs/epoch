sinon = require 'sinon'

describe 'Epoch.Time.Plot', ->
  # Helper that builds data layers with specific ranges
  layerWithRange = (min, max, range) ->
    layer = { values: [{time: 0, y: min}, {time: 1, y: max}] }
    layer.range = range if range?
    layer

  chart = null

  beforeEach ->
    chart = new Epoch.Time.Plot(data: [layerWithRange(0, 100)])

  describe '_getScaleDomain', ->
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
        chart = new Epoch.Time.Plot
          data: [
            layerWithRange(0, 10, 'left'),
            layerWithRange(-5000, 5000, 'right'),
            layerWithRange(-10, -5, 'left')
          ]

      it 'returns the extent of the layers with the given range label', ->
        assert.deepEqual chart._getScaleDomain('left'), [-10, 10]

      it 'returns the extent of the data if the label is invalid', ->
        assert.deepEqual chart._getScaleDomain('foobar'), chart.extent((d) -> d.y)

  describe 'y', ->
    scaleDomain = [-524, 2324]
    beforeEach -> sinon.stub(chart, '_getScaleDomain').returns(scaleDomain)
    afterEach -> chart._getScaleDomain.restore()

    it 'should get the scale domain from the given domain', ->
      y = chart.y('a')
      assert.ok chart._getScaleDomain.calledWith('a')
      assert.deepEqual y.domain(), scaleDomain

  describe 'ySvg', ->
    scaleDomain = [3004, 10000000]
    beforeEach -> sinon.stub(chart, '_getScaleDomain').returns(scaleDomain)
    afterEach -> chart._getScaleDomain.restore()

    it 'should get the scale domain from the given domain', ->
      y = chart.ySvg('a')
      assert.ok chart._getScaleDomain.calledWith('a')
      assert.deepEqual y.domain(), scaleDomain

  describe 'ySvgLeft', ->
    beforeEach -> sinon.spy(chart, 'ySvg')
    afterEach -> chart.ySvg.restore()

    it 'should use the left range when present', ->
      chart.options.range = { left: 'apples' }
      chart.ySvgLeft()
      assert.ok chart.ySvg.calledWith('apples')

    it 'should not use the left range when missing', ->
      chart.ySvgLeft()
      assert.ok chart.ySvg.calledOnce

  describe 'ySvgRight', ->
    beforeEach -> sinon.spy(chart, 'ySvg')
    afterEach -> chart.ySvg.restore()

    it 'should use the right range when present', ->
      chart.options.range = { right: 'oranges' }
      chart.ySvgRight()
      assert.ok chart.ySvg.calledWith('oranges')

    it 'should not use the right range when missing', ->
      chart.ySvgRight()
      assert.ok chart.ySvg.calledOnce

  describe 'leftAxis', ->
    beforeEach -> sinon.spy chart, 'ySvgLeft'
    afterEach -> chart.ySvgLeft.restore()
    it 'uses the left svg scale', ->
      chart.leftAxis()
      assert.ok chart.ySvgLeft.calledOnce

  describe 'rightAxis', ->
    beforeEach -> sinon.spy chart, 'ySvgRight'
    afterEach -> chart.ySvgRight.restore()
    it 'uses the right svg scale', ->
      chart.rightAxis()
      assert.ok chart.ySvgRight.calledOnce
