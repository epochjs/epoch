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

    it 'should set the appropriate postfix based on the number\'s order of magnitude', ->
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


  describe 'formatBytes', ->
    it 'should postfix numbers < 1024 with "B"', ->
      number = 512
      match = Epoch.Util.formatBytes(number).match(/B$/)
      assert.isNotNull match
      assert.equal match.length, 1
      assert.equal match[0], 'B'

    it 'should only set a fixed decimal for integers when instructed', ->
      number = 128
      match = Epoch.Util.formatBytes(number, 1, true).match('.0')
      assert.isNotNull match
      assert.equal match[0], '.0'

    it 'should set the appropriate number of fixed digits', ->
      number = 3.1415
      for i in [1..5]
        fixed = Epoch.Util.formatBytes(number, i).replace(/\sB$/, '')
        assert.isString fixed
        match = fixed.split('.')[1]
        assert.isNotNull match
        assert.equal match.length, i

    it 'should set the appropriate postfix based on the number\'s order of magnitude', ->
      for i, postfix of ['KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB']
        number = Math.pow(1024, (i|0)+1)
        regexp = new RegExp(" #{postfix}$")
        assert.isNotNull Epoch.Util.formatBytes(number).match(regexp)

