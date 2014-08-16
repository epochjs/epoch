
describe 'Epoch.Chart.options', ->
  it 'should set the type option to "area" for basic area charts', ->
    assert.equal new Epoch.Chart.Area().options.type, 'area'

  it 'should set the type option to "bar" for basic bar charts', ->
    assert.equal new Epoch.Chart.Bar().options.type, 'bar'

  it 'should set the type option to "histogram" for basic histogram charts', ->
    assert.equal new Epoch.Chart.Histogram().options.type, 'histogram'

  it 'should set the type option to "line" for basic line charts', ->
    assert.equal new Epoch.Chart.Line().options.type, 'line'

  it 'should set the type option to "pie" for basic pie charts', ->
    assert.equal new Epoch.Chart.Pie().options.type, 'pie'

  it 'should set the type option to "scatter" for basic scatter charts', ->
    assert.equal new Epoch.Chart.Scatter().options.type, 'scatter'

  it 'should set the type option to "time.area" for real-time area charts', ->
    assert.equal new Epoch.Time.Area().options.type, 'time.area'

  it 'should set the type option to "time.bar" for real-time bar charts', ->
    assert.equal new Epoch.Time.Bar().options.type, 'time.bar'

  it 'should set the type option to "time.gauge" for real-time gauge charts', ->
    assert.equal new Epoch.Time.Gauge().options.type, 'time.gauge'

  it 'should set the type option to "time.heatmap" for real-time heatmap charts', ->
    assert.equal new Epoch.Time.Heatmap().options.type, 'time.heatmap'

  it 'should set the type option to "time.line" for real-time line charts', ->
    assert.equal new Epoch.Time.Line().options.type, 'time.line'

describe 'Epoch.Chart._formatData', ->
  assertBasicData = (klassName, type) ->
    data = [1, 2, 3, 4]
    expected = Epoch.data 'array', data, {type: type}
    chart = new Epoch.Chart[klassName]
      data: data
      dataFormat: 'array'
    assert.data expected, chart.data

  assertTimeData = (klassName, type) ->
    data = [1, 2, 3, 4]
    expected = Epoch.data 'array', data, {type: type, time: (d, i) -> parseInt(i)}
    chart = new Epoch.Time[klassName]
      data: data
      dataFormat:
        name: 'array'
        options: { time: (d, i) -> parseInt(i) }
    assert.timeData expected, chart.data

  it 'should correctly detect and format array type data', ->
    data = [1, 2, 3]
    expected = Epoch.data 'array', data
    chart = new Epoch.Chart.Base
      data: data
      dataFormat: 'array'
    assert.data expected, chart.data

  it 'should correctly detect and format tuple type data', ->
    data = [[1, 1], [2, 4], [3, 78]]
    expected = Epoch.data 'tuple', data
    chart = new Epoch.Chart.Base
      data: data
      dataFormat: 'tuple'
    assert.data expected, chart.data

  it 'should correctly detect and format keyvalue type data', ->
    data = [ {a: 20, b: 30, x: 10}, {a: 40, b: 50, x: 20} ]
    expected = Epoch.data 'keyvalue', data, ['a', 'b'], { x: (d) -> d.x }
    chart = new Epoch.Chart.Base
      data: data
      dataFormat:
        name: 'keyvalue'
        arguments: [['a', 'b']]
        options: { x: (d, i) -> d.x }
    assert.data expected, chart.data

  it 'should correctly format area chart data', ->
    assertBasicData 'Area', 'area'

  it 'should correctly format bar chart data', ->
    assertBasicData 'Bar', 'bar'

  it 'should correctly format line data', ->
    assertBasicData 'Line', 'line'

  it 'should correctly format scatter data', ->
    assertBasicData 'Scatter', 'scatter'

  it 'should correctly format pie data', ->
    data = [1, 2, 3]
    expected = data.map (d) -> {value: d}
    result = (new Epoch.Chart.Pie(data: data, dataFormat: 'array')).data
    for i in [0...expected.length]
      assert.equal expected[i].value, result[i].value
    
  it 'should correctly format histogram data', ->
    data = (parseInt(Math.random() * 100) for i in [0...100])
    format = Epoch.data('array', data, { type: 'histogram' })
    expected = (new Epoch.Chart.Histogram())._prepareData(format)
    chart = new Epoch.Chart.Histogram({ data: data, dataFormat: 'array' })
    assert.data expected, chart.data

  it 'should correctly format real-time area data', ->
    assertTimeData 'Area', 'time.area'

  it 'should correctly format real-time bar data', ->
    assertTimeData 'Bar', 'time.bar'

  it 'should correctly format real-time heatmap data', ->
    assertTimeData 'Heatmap', 'time.heatmap'

  it 'should correctly format real-time line data', ->
    assertTimeData 'Line', 'time.line'



