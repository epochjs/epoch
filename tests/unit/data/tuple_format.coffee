describe 'Epoch.Data.Format.tuple', ->
  it 'should format flat tuple arrays', ->
    input = [[1, 2], [3, 4], [5, 6]]
    expected = [{values: input.map((d) -> {x: d[0], y: d[1]})}]
    result = Epoch.Data.Format.tuple(input)
    assert.data expected, result

  it 'should format nested layers of tuple arrays', ->
    input = [
      [ [1, 2], [3, 4] ],
      [ [5, 6], [7, 8] ]
    ]
    expected = input.map (series) ->
      {values: series.map((d) -> {x: d[0], y: d[1]})}
    result = Epoch.Data.Format.tuple(input)
    assert.data expected, result

  it 'should respect the x option', ->
    input = [[1, 2], [3, 4], [5, 6]]
    expected = [{values: input.map((d, i) -> {x: i, y: d[1]})}]
    result = Epoch.Data.Format.tuple(input, {x: (d, i) -> i})
    assert.data expected, result

  it 'should respect the y option', ->
    input = [[1, 2], [3, 4], [5, 6]]
    expected = [{values: input.map((d, i) -> {x: d[0], y: i})}]
    result = Epoch.Data.Format.tuple(input, {y: (d, i) -> i})
    assert.data expected, result

  it 'should format flat tuples of real-time data', ->
    input = [[1, 2], [3, 4], [5, 6]]
    expected = [{values: input.map((d) -> {time: d[0], y: d[1]})}]
    result = Epoch.Data.Format.tuple(input, {type: 'time.line'})
    assert.data expected, result

  it 'should format nested layers of real-time tuple data', ->
    input = [
      [ [1, 2], [3, 4] ],
      [ [5, 6], [7, 8] ]
    ]
    expected = input.map (series) ->
      {values: series.map((d) -> {time: d[0], y: d[1]})}
    result = Epoch.Data.Format.tuple(input, {type: 'time.line'})
    assert.data expected, result

  it 'should respect the time option', ->
    input = [[1, 2], [3, 4], [5, 6]]
    expected = [{values: input.map((d, i) -> {time: i, y: d[1]})}]
    result = Epoch.Data.Format.tuple(input, {type: 'time.line', time: (d, i) -> i})
    assert.data expected, result

  it 'should ignore heatmap, pie, and gauge charts', ->
    input = [[1, 2], [3, 4], [5, 6]]
    assert.equal 0, Epoch.Data.Format.tuple(input, {type: 'time.heatmap'}).length
    assert.equal 0, Epoch.Data.Format.tuple(input, {type: 'time.gauge'}).length
    assert.equal 0, Epoch.Data.Format.tuple(input, {type: 'pie'}).length

  it 'should produce single series entries correctly', ->
    input = [5, 6]
    result = Epoch.Data.Format.tuple.entry(input)
    assert.isArray result
    assert.equal 1, result.length
    assert.isObject result[0]
    assert.equal input[0], result[0].x
    assert.equal input[1], result[0].y

  it 'should produce multi-series entries correctly', ->
    input = [[5, -10], [4, 8], [2, 3]]
    expected = ({x: d[0], y: d[1]} for d in input)
    result = Epoch.Data.Format.tuple.entry(input)
    assert.isArray result
    assert.equal expected.length, result.length
    for i in [0...expected.length]
      assert.isObject result[i]
      assert.equal expected[i].x, result[i].x
      assert.equal expected[i].y, result[i].y
