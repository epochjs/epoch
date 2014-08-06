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
