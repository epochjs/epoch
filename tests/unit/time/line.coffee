sinon = require 'sinon'

describe 'Epoch.Time.Line', ->
  chart = null
  beforeEach ->
    chart = new Epoch.Time.Line
      data: [{ range: 'foo', values: [{time: 0, y: 10}, {time: 1, y: 30}] }]

  describe 'draw', ->
    beforeEach -> sinon.spy chart, 'y'
    afterEach -> chart.y.restore()

    it 'should provide the layer\'s range to the y scale', ->
      chart.draw()
      assert.ok chart.y.calledWith('foo')
