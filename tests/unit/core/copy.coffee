describe 'Epoch.Util', ->
  describe 'copy', ->
    it 'should correctly create a shallow copy', ->
      object =
        a: 20
        b: 'hello'

      copy = Epoch.Util.copy(object)

      assert.equal copy.a, object.a
      assert.equal copy.b, object.b

    it 'should not recursively copy objects', ->
      object =
        a:
          foo: 'bar'

      copy = Epoch.Util.copy(object)
      object.a.foo = 'baz'
      assert.equal object.a.foo, copy.a.foo

  describe 'defaults', ->
    it 'should set default values when keys are missing', ->
      options = {a: 'foo', b: 'bar'}
      defaults = {c: 'baz'}
      result = Epoch.Util.defaults(options, defaults)
      assert.equal result.c, defaults.c

    it 'should not set default values when keys are present', ->
      options = { a: 'foo', b: 'bar' }
      defaults = { a: 'wow', b: 'neat' }
      result = Epoch.Util.defaults(options, defaults)
      assert.equal result.a, options.a
      assert.equal result.b, options.b

    it 'should recursively set defaults from sub objects', ->
      options =
        a:
          b: 'foo'
      defaults =
        a:
          b: ''
          c: 'bar'
      result = Epoch.Util.defaults(options, defaults)

      assert.equal result.a.b, options.a.b
      assert.equal result.a.c, defaults.a.c
