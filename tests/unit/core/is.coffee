describe 'Epoch.Util', ->
  describe 'isArray', ->
    it 'should return true if given an array', ->
      assert.ok Epoch.isArray([])
      assert.ok Epoch.isArray([1, 2, 3])

    it 'should return false if not given an array', ->
      assert.notOk Epoch.isArray(2)
      assert.notOk Epoch.isArray("hello")
      assert.notOk Epoch.isArray({})

  describe 'isObject', ->
    it 'should return true if given an flat object', ->
      assert.ok Epoch.isObject({})

    it 'should return false if given a number object', ->
      assert.notOk Epoch.isObject(new Number())

    it 'should return false if given a non-object', ->
      assert.notOk Epoch.isObject([])
      assert.notOk Epoch.isObject(2)
      assert.notOk Epoch.isObject("string")

  describe 'isString', ->
    it 'should return true if given a string', ->
      assert.ok Epoch.isString("example")
      assert.ok Epoch.isString(new String())

    it 'should return false if given a non-string', ->
      assert.notOk Epoch.isString(2)
      assert.notOk Epoch.isString([])
      assert.notOk Epoch.isString({})

  describe 'isFunction', ->
    it 'should return true if given a function', ->
      assert.ok Epoch.isFunction(->)

    it 'should return false if given a non-function', ->
      assert.notOk Epoch.isFunction([])
      assert.notOk Epoch.isFunction({})
      assert.notOk Epoch.isFunction(42)
      assert.notOk Epoch.isFunction("cool")

  describe 'isNumber', ->
    it 'should return true if given a number', ->
      assert.ok Epoch.isNumber(new Number())

    it 'should return true if given an integer literal', ->
      assert.ok Epoch.isNumber(1983)

    it 'should return true if given a floating point literal', ->
      assert.ok Epoch.isNumber(3.1415)

    it 'should return false if given a non-number', ->
      assert.notOk Epoch.isNumber(->)
      assert.notOk Epoch.isNumber([])
      assert.notOk Epoch.isNumber({})
      assert.notOk Epoch.isNumber("nan")

  describe 'isElement', ->
    it 'should return true given an html element', ->
      p = doc.createElement('P')
      assert.ok Epoch.isElement(p)

    it 'should return false given a non-element', ->
      assert.notOk Epoch.isElement(1)
      assert.notOk Epoch.isElement("1")
      assert.notOk Epoch.isElement({})
      assert.notOk Epoch.isElement([])
      assert.notOk Epoch.isElement(->)

  describe 'isNonEmptyArray', ->
    it 'should return true given a non-empty array', ->
      assert.ok Epoch.isNonEmptyArray([1])
      assert.ok Epoch.isNonEmptyArray([1, 3])
      assert.ok Epoch.isNonEmptyArray(["foo", 4, "bar"])

    it 'should return false given a non-array', ->
      assert.notOk Epoch.isNonEmptyArray(2)
      assert.notOk Epoch.isNonEmptyArray("five")
      assert.notOk Epoch.isNonEmptyArray({})
      assert.notOk Epoch.isNonEmptyArray(->)

    it 'should return false given a null value', ->
      assert.notOk Epoch.isNonEmptyArray(null)

    it 'should return false given an empty array', ->
      assert.notOk Epoch.isNonEmptyArray([])
