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

  describe 'toRGBA', ->
    it 'should produce the correct rgba style when given an rgba color style', ->
      assert.equal Epoch.Util.toRGBA('rgba(1, 2, 3, 0.4)', 0.1), 'rgba(1,2,3,0.1)'

    it 'should produce the correct rgba style when given any rgb color style', ->
      assert.equal Epoch.Util.toRGBA('black', 0.25), 'rgba(0,0,0,0.25)'
      assert.equal Epoch.Util.toRGBA('#FF0000', 0.9), 'rgba(255,0,0,0.9)'
      assert.equal Epoch.Util.toRGBA('rgb(10, 20, 40)', 0.99), 'rgba(10,20,40,0.99)'

  describe 'getComputedStyle', ->
    overrideStyles =
      'width': '320px'
      'height': '240px'
      'background-color': 'blue'

    [style, div] = [null, null]

    before (done) ->
      style = addStyleSheet('#get-style-div { padding-left: 30px; background: green }')
      div = doc.createElement('div')
      div.id = 'get-style-div'
      doc.body.appendChild(div)
      d3.select('#get-style-div').style(overrideStyles)
      done()

    after (done) ->
      doc.body.removeChild(div)
      doc.head.removeChild(style)
      done()

    it 'should find <style> styles', ->
      styles = Epoch.Util.getComputedStyle(div)
      assert.equal styles['padding-left'], '30px'

    it 'should find overriden styles', ->
      styles = Epoch.Util.getComputedStyle(div)
      for k, v of overrideStyles
        assert.equal styles[k], v, "ComputedStyles['#{k}'] should be '#{v}'"

  describe 'flatten', ->
    it 'should flatten a given multi-array', ->
      multiarray = [[1, 2], 3, [4, 5, 6, [7]]]
      expected = [1, 2, 3, 4, 5, 6, [7]]
      assert.deepEqual Epoch.Util.flatten(multiarray), expected

    it 'should throw if given a non-array', ->
      assert.throws (-> Epoch.Util.flatten null), /only accepts arrays/
      assert.throws (-> Epoch.Util.flatten 1), /only accepts arrays/
      assert.throws (-> Epoch.Util.flatten {}), /only accepts arrays/
      assert.throws (-> Epoch.Util.flatten 'hellooo'), /only accepts arrays/
      assert.throws (-> Epoch.Util.flatten new Error()), /only accepts arrays/
