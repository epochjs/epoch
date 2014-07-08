describe 'd3.selection', ->
  [width, height] = [345, 543, null]
  [element, id] = [null, 'd3-element']

  before (done) ->
    element = doc.createElement('DIV')
    element.id = id
    doc.body.appendChild(element)
    d3.select('#' + id).style
      'width': width + "px"
      'height': height + "px"
    done()

  describe 'width', ->
    it 'should return the width of an element', ->
      assert.equal d3.select('#' + id).width(), width

    it 'should set the width of an element given a number', ->
      widthNumber = 50
      d3.select('#'+id).width(widthNumber)
      assert.equal d3.select('#'+id).width(), widthNumber

    it 'should set the width of an element given a css pixel length', ->
      widthString = '500px'
      d3.select('#'+id).width(widthString)
      assert.equal d3.select('#'+id).width(), +widthString.replace('px', '')

  describe 'height', ->
    it 'should return the height of an element', ->
      assert.equal d3.select('#' + id).height(), height

    it 'should set the height of an element given a number', ->
      heightNumber = 75
      d3.select('#'+id).height(heightNumber)
      assert.equal d3.select('#'+id).height(), heightNumber

    it 'should set the height of an element given a css pixel length', ->
      heightString = '343px'
      d3.select('#'+id).height(heightString)
      assert.equal d3.select('#'+id).height(), +heightString.replace('px', '')
