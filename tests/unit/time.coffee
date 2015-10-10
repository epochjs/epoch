sinon = require 'sinon'

describe 'Epoch.Time.Plot', ->
  chart = null

  beforeEach ->
    chart = new Epoch.Time.Plot(data: [layerWithRange(0, 100)])

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
