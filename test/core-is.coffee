jsdom = require('jsdom')
assert = require('assert')

describe 'Epoch.Util', ->
  Epoch = null
  HTMLElement = null
  document = null
  
  before (done) ->
    jsdom.env
      html: "<html><body></body></html>"
      scripts: ["http://d3js.org/d3.v3.min.js", "../js/epoch.js"]
      done: (errors, window) ->
        Epoch = window.Epoch
        HTMLElement = window.HTMLElement
        document = window.document
        done()

  describe 'isArray', ->
    it 'should return true if given an array', ->
      assert.equal Epoch.isArray([]), true
      assert.equal Epoch.isArray([1, 2, 3]), true

    it 'should return false if not given an array', ->
      assert.equal Epoch.isArray(2), false
      assert.equal Epoch.isArray("hello"), false
      assert.equal Epoch.isArray({}), false

  describe 'isObject', ->
    it 'should return true if given an flat object', ->
      assert.equal Epoch.isObject({}), true

    it 'should return false if given a number object', ->
      assert.equal Epoch.isObject(new Number()), false

    it 'should return false if given a non-object', ->
      assert.equal Epoch.isObject([]), false
      assert.equal Epoch.isObject(2), false
      assert.equal Epoch.isObject("string"), false

  describe 'isString', ->
    it 'should return true if given a string', ->
      assert.equal Epoch.isString("example"), true
      assert.equal Epoch.isString(new String()), true

    it 'should return false if given a non-string', ->
      assert.equal Epoch.isString(2), false
      assert.equal Epoch.isString([]), false
      assert.equal Epoch.isString({}), false

  describe 'isFunction', ->
    it 'should return true if given a function', ->
      assert.equal Epoch.isFunction(->), true

    it 'should return false if given a non-function', ->
      assert.equal Epoch.isFunction([]), false
      assert.equal Epoch.isFunction({}), false
      assert.equal Epoch.isFunction(42), false
      assert.equal Epoch.isFunction("cool"), false

  describe 'isNumber', ->
    it 'should return true if given a number', ->
      assert.equal Epoch.isNumber(new Number()), true

    it 'should return true if given an integer literal', ->
      assert.equal Epoch.isNumber(1983), true

    it 'should return true if given a floating point literal', ->
      assert.equal Epoch.isNumber(3.1415), true

    it 'should return false if given a non-number', ->
      assert.equal Epoch.isNumber(->), false
      assert.equal Epoch.isNumber([]), false
      assert.equal Epoch.isNumber({}), false
      assert.equal Epoch.isNumber("nan"), false

  describe 'isElement', ->
    it 'should return true given an html element', ->
      p = document.createElement('P')
      assert.equal Epoch.isElement(p), true

    it 'should return false given a non-element', ->
      assert.equal Epoch.isElement(1), false
      assert.equal Epoch.isElement("1"), false
      assert.equal Epoch.isElement({}), false
      assert.equal Epoch.isElement([]), false
      assert.equal Epoch.isElement(->), false





