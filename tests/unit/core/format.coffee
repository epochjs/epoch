describe 'Epoch.Util', ->
  describe 'formatSI', ->
    it 'should produce the same number for integers < 1000', ->
      number = 678
      assert.equal Epoch.Util.formatSI(number), number

    it 'should only set a fixed decimal for integers when instructed', ->
      number = 20
      assert.equal Epoch.Util.formatSI(number), number
      assert.equal Epoch.Util.formatSI(number, 1, true), "#{number}.0"
      
    it 'should set the appropriate number of fixed digits', ->
      number = 3.1415
      for i in [1..5]
        match = Epoch.Util.formatSI(number, i).split('.')[1]
        assert.isNotNull match
        assert.isString match
        assert.equal match.length, i

    it 'should set the appropriate postfix based on the number\'s order of magnitude', ->
      for i, postfix of ['K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y']
        number = Math.pow(10, ((i|0)+1)*3)
        assert.equal Epoch.Util.formatSI(number), "1 #{postfix}"


  describe 'formatBytes', ->
    it 'should postfix numbers < 1024 with "B"', ->
      number = 512
      assert.equal Epoch.Util.formatBytes(number), "#{number} B"

    it 'should only set a fixed decimal for integers when instructed', ->
      assert.equal Epoch.Util.formatBytes(128), '128 B'
      assert.equal Epoch.Util.formatBytes(128, 1, true), '128.0 B'
      assert.equal Epoch.Util.formatBytes(1024), '1 KB'
      assert.equal Epoch.Util.formatBytes(1024, 1, true), '1.0 KB'

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


describe 'Epoch.Formats', ->
  describe 'regular', ->
    it 'should return what it was given', ->
      assert.equal Epoch.Formats.regular(10), 10
      assert.equal Epoch.Formats.regular("hello"), "hello"

  describe 'percent', ->
    it 'should return a percent given a number', ->
      assert.equal Epoch.Formats.percent(0.1), '10.0%'
      assert.equal Epoch.Formats.percent(0.5), '50.0%'
      assert.equal Epoch.Formats.percent(1), '100.0%'
      assert.equal Epoch.Formats.percent(23.245), '2324.5%'

  describe 'seconds', ->
    it 'should return a well formatted date given a timestamp', ->
      assert.equal Epoch.Formats.seconds(1404385979), '04:12:59 AM'
