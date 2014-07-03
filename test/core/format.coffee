describe 'Epoch.Util', ->


  describe 'formatSI', ->
    it 'should produce the same number for integers < 1000', ->
      number = 678
      result = Epoch.Util.formatSI(number)
      assert.equal result, number

    it 'should only set a fixed decimal for integers when instructed', ->
      number = 20
      assert.equal Epoch.Util.formatSI(number), number
      match = Epoch.Util.formatSI(number, 1, true).match(/\.0$/)
      assert.equal match.length, 1
      assert.equal match[0], '.0'

    it 'should set the appropriate number of fixed digits', ->
      number = 3.1415
      for i in [1..5]
        match = Epoch.Util.formatSI(number, i).split('.')[1]
        assert.isNotNull match
        assert.isString match
        assert.equal match.length, i

    it 'should set the appropriate postfix based on the numbers order of magnitude', ->
      orderMap =
        'K': 3
        'M': 6
        'G': 9
        'T': 12
        'P': 15
        'E': 18
        'Z': 21
        'Y': 24

      for postfix, power of orderMap
        number = Math.pow(10, power)
        result = Epoch.Util.formatSI(number)
        assert.isString result
        assert.notEqual result.length, 0
        assert.equal result.indexOf(postfix), result.length - 1



    #it 'should append a K for numbers greater than 1K but less than 1M',

