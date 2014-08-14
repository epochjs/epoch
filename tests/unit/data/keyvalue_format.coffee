describe 'Epoch.Data.Format.keyvalue', ->

  data = [
    { x: 1, a: 20, b: 30, c: 40, hist: 10, time: 0 },
    { x: 2, a: 45, b: 83, c: 8,  hist: 11, time: 1 },
    { x: 3, a: 17, b: 72, c: 54, hist: 12, time: 2 },
    { x: 4, a: 99, b: 19, c: 39, hist: 13, time: 3 }
  ]

  it 'should format a single series for basic plots', ->
    expected = [{ values: (data.map (d, i) -> { x: parseInt(i), y: d.a }) }]
    result = Epoch.Data.Format.keyvalue(data, ['a'])
    assert.data expected, result

  it 'should format multiple series for basic plots', ->
    expected = [
      { values: (data.map (d, i) -> {x: parseInt(i), y: d.a }) },
      { values: (data.map (d, i) -> {x: parseInt(i), y: d.b }) },
      { values: (data.map (d, i) -> {x: parseInt(i), y: d.c }) }
    ]
    result = Epoch.Data.Format.keyvalue(data, ['a', 'b', 'c'])
    assert.data expected, result

  it 'should format a single series for real-time plots', ->
    expected = [
      { values: (data.map (d, i) -> { time: d.time, y: d.a }) }
    ]
    result = Epoch.Data.Format.keyvalue(data, ['a'], { type: 'time.line', time: (d) -> d.time })
    assert.data expected, result

  it 'should format multiple series for real-time plots', ->
    expected = [
      { values: (data.map (d, i) -> { time: d.time, y: d.a }) }
      { values: (data.map (d, i) -> { time: d.time, y: d.b }) }
      { values: (data.map (d, i) -> { time: d.time, y: d.c }) }
    ]
    result = Epoch.Data.Format.keyvalue(data, ['a', 'b', 'c'], { type: 'time.line', time: (d) -> d.time })
    assert.data expected, result

  it 'should correctly format heatmap data', ->
    expected = [
      { values: (data.map (d, i) -> {time: d.time, histogram: d.hist }) }
    ]
    result = Epoch.Data.Format.keyvalue(data, ['hist'], {type: 'time.heatmap', time: ((d) -> d.time) })
    assert.data expected, result

  it 'should return an empty set for type time.gauge and type pie', ->
    assert.equal Epoch.Data.Format.keyvalue(data, ['a'], {type: 'pie'}).length, 0
    assert.equal Epoch.Data.Format.keyvalue(data, ['a'], {type: 'time.gauge'}).length, 0

  it 'should respect the x option', ->
    expected = [{ values: (data.map (d, i) -> {x: d.x, y: d.a }) }]
    result = Epoch.Data.Format.keyvalue(data, ['a'], {x: (d) -> d.x})
    assert.data expected, result

  it 'should respect the y option', ->
    expected = [{ values: (data.map (d, i) -> {x: parseInt(i), y: d.a + 2 }) }]
    result = Epoch.Data.Format.keyvalue(data, ['a'], {y: (d) -> d + 2})
    assert.data expected, result    

  it 'should apply key name labels by default', ->
    labels = ['a', 'b', 'c', 'hist']
    layers = Epoch.Data.Format.keyvalue(data, ['a', 'b', 'c', 'hist'])
    for i in [0...labels.length]
      assert.equal labels[i], layers[i].label

  it 'should override key name labels with given labels', ->
    labels = ['x', 'y', 'z']
    layers = Epoch.Data.Format.keyvalue(data, ['a', 'b', 'c'], {labels: labels})
    for i in [0...labels.length]
      assert.equal labels[i], layers[i].label

  it 'should apply automatic labels only when labels are not given and key labels are off', ->
    labels = ['A', 'B']
    layers = Epoch.Data.Format.keyvalue(data, ['a', 'b'], {keyLabels: false, autoLabels: true})
    for i in [0...labels.length]
      assert.equal labels[i], layers[i].label

  it 'should produce single series entries correctly', ->
    input = data[0]
    keys = ['a']
    expected = [{x: 0, y: input.a}]
    result = Epoch.Data.Format.keyvalue.entry(input, keys)
    assert.isArray result
    assert.equal 1, result.length
    assert.isObject result[0]
    assert.equal 0, result[0].x
    assert.equal input.a, result[0].y

  it 'should produce multi-series entries correctly', ->
    input = data[1]
    keys = ['a', 'b', 'c']
    options = {x: 'x'}
    expected = ({x: input.x, y: input[key]} for key in keys)
    result = Epoch.Data.Format.keyvalue.entry(input, keys, options)
    assert.isArray result
    assert.equal expected.length, result.length
    for i in [0...expected.length]
      assert.isObject result[i]
      assert.equal expected[i].x, result[i].x
      assert.equal expected[i].y, result[i].y
