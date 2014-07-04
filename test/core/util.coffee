describe 'Epoch.Util', ->
  describe 'trim', ->
    it 'should return null unless given a string', ->
      assert.isNotNull Epoch.Util.trim('test string')
      assert.isNull Epoch.Util.trim(34)

    it 'should trim leading and trailing whitespace', ->
      assert.equal Epoch.Util.trim("\t\n\r indeed \n\t\t\r"), 'indeed'

    it 'should leave inner whitespace', ->
      assert.equal Epoch.Util.trim('Hello world'), 'Hello world'

  describe 'dasherize', ->
    it 'should dasherize regular strings', ->
      assert.equal Epoch.Util.dasherize('Hello World'), 'hello-world'

    it 'should trim leading and trailing whitespace before dasherizing', ->
      assert.equal Epoch.Util.dasherize('  Airieee is KewL '), 'airieee-is-kewl'

  describe 'domain', ->
    testLayers = [
      { values: [{x: 'A', y: 10}, {x: 'B', y: 20}, {x: 'C', y: 40}] }
    ]

    testLayers2 = [
      { values: [{x: 'A', y: 10}, {x: 'B', y: 20}, {x: 'C', y: 40}] },
      { values: [{x: 'D', y: 15}, {x: 'E', y: 30}, {x: 'F', y: 90}] }
    ]

    it 'should find the correct domain of a set of keys and values', ->
      xDomain = Epoch.Util.domain(testLayers, 'x')
      assert.sameMembers xDomain, ['A', 'B', 'C']
      yDomain = Epoch.Util.domain(testLayers, 'y')
      assert.sameMembers yDomain, [10, 20, 40]

    it 'should find all the values across multiple layers', ->
      xDomain = Epoch.Util.domain(testLayers2, 'x')
      assert.sameMembers xDomain, ['A', 'B', 'C', 'D', 'E', 'F']
      yDomain = Epoch.Util.domain(testLayers2, 'y')
      assert.sameMembers yDomain, [10, 20, 40, 15, 30, 90]
