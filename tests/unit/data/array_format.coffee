describe 'Epoch.DataFormat.array', ->
  assertData = (expected, result, checkAttributes) ->
    checkAttributes ?= ['x', 'y']
    assert.equal expected.length, result.length
    for i, layer of expected
      resultLayer = result[i]
      msg = "Result layer #{i} does not have expected number of values."
      assert.equal layer.values.length, resultLayer.values.length, msg
      for j in [0...layer.values.length]
        for k in checkAttributes
          msg = "Layer #{i} data point #{j} does not have the expected value for key #{k}"
          assert.equal layer.values[j][k], resultLayer.values[j][k], msg

  assertTimeData = (expected, result) ->
    assertData(expected, result, ['time', 'y'])

  startTime = 1000

  it 'should format flat arrays', ->
    expected = [ {values: [{x: 0, y: 1}, {x: 1, y: 2}, {x: 2, y: 3}]} ]
    assertData expected, Epoch.DataFormat.array([1, 2, 3])

  it 'should format multi-dimensional arrays', ->
    expected = [
      { values: [{x: 0, y: 1}, {x: 1, y: 2}]},
      { values: [{x: 0, y: 3}, {x: 1, y: 4}]}
    ]
    assertData expected, Epoch.DataFormat.array([[1, 2], [3, 4]])

  it 'should respect the x option', ->
    expected = [{values: [{x: 1, y: 1}, {x: 2, y: 2}]}]
    result = Epoch.DataFormat.array [1, 2], {x: (d, i) -> i+1}
    assertData expected, result

  it 'should respect the y option', ->
    expected = [{values: [{x: 0, y: 2}, {x: 1, y: 4}]}]
    result = Epoch.DataFormat.array [1, 2], {y: (d) -> d*2}
    assertData expected, result   

  it 'should format pie chart data with flat arrays', ->
    input = [20, 30, 40]
    expected = ({value: v} for v in input)
    result = Epoch.DataFormat.array input, {type: 'pie'}
    assert.equal expected.length, result.length, "Result did not have the expected number of layers"
    for i in [0...expected.length]
      assert.equal expected[i].value, result[i].value, "Result #{i} did not have the epected value"

  it 'should not format pie chart data with multi-dimensional arrays', ->
    assert.equal Epoch.DataFormat.array([[1], [2]], {type: 'pie'}).length, 0

  it 'should format real-time plot data with flat arrays', ->
    input = [1, 2, 3]
    expected = [{ values: ({time: startTime+parseInt(i), y: v} for i,v of input) }]
    result = Epoch.DataFormat.array(input, {type: 'time.line', startTime: startTime})
    assertTimeData expected, result

  it 'should format real-time plot data with multi-dimensional arrays', ->
    input = [[1, 2], [3, 4]]
    expected = []
    for layer in input
      expected.push {values: ({time: startTime+parseInt(i), y: v} for i, v of layer)}
    result = Epoch.DataFormat.array(input, {type: 'time.line', startTime: startTime})
    assertTimeData expected, result

  it 'should format heatmap data with flat arrays', ->
    input = [{'1': 1, '2': 2}, {'3': 3, '4': 4}]
    expected = [{values: ({time: startTime+parseInt(i), histogram: h} for i, h of input)}]
    result = Epoch.DataFormat.array(input, {type: 'time.heatmap', startTime: startTime})
    assertData expected, result, ['time', 'heatmap']

  it 'should format heatmap data with multi-dimensional arrays', ->
    input = [
      [{'1': 1, '2': 2}, {'3': 3, '4': 4}],
      [{'5': 5, '6': 6}, {'7': 7, '8': 8}]
    ]
    expected = [
      { values: ({time: startTime+parseInt(i), histogram: h} for i, h of input[0]) },
      { values: ({time: startTime+parseInt(i), histogram: h} for i, h of input[1]) },
    ]
    result = Epoch.DataFormat.array(input, {type: 'time.heatmap', startTime: startTime})
    assertData expected, result, ['time', 'heatmap']

  it 'should correctly apply labels if the labels option is present', ->
    labels = ['alpha', 'beta']
    result = Epoch.DataFormat.array [[1], [2]], {labels: labels}
    for i in [0...labels.length]
      assert.equal labels[i], result[i].label

  it 'should correctly apply labels if the autoLabels option is set', ->
    labels = ['A', 'B', 'C']
    result = Epoch.DataFormat.array [[1], [2], [3]], {autoLabels: true}
    for i in [0...labels.length]
      assert.equal labels[i], result[i].label

  it 'should prefer the labels option to the autoLabels option if both are set', ->
    labels = ['alpha', 'beta']
    result = Epoch.DataFormat.array [[1], [2]], {labels: labels, autoLabels: true}
    for i in [0...labels.length]
      assert.equal labels[i], result[i].label
