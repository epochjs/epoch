describe 'Epoch.QueryCSS', ->
  styleMap =
    '#container rect':
      'fill': 'blue'
      'stroke': 'red'
      'stroke-width': '5px'
    '#container rect.a':
      'fill': 'green'
      'stroke': 'yellow'
      'stroke-width': '1px'
    'rect#byid':
      'fill': 'purple'
      'stroke': '#94105A'
      'stroke-width': '15px'
    'body.alt-color rect#byid':
      'fill': '#abcdef1'
      'stroke': '#48419A'
      'stroke-width': '2em'

  [container, svg, styleTag] = [null, null, null]

  makeStyleSheet = ->
    cssStatements = []
    for selector, rules of styleMap
      cssStatements.push (selector + "{" + ("#{k}: #{v}" for k, v of rules).join(';') + "}")
    css = cssStatements.join('\n')
    styleTag = addStyleSheet(css)

  makeContainer = ->
    container = d3.select(doc.body).append('div')
      .attr('id', 'container')
    svg = container.append('svg')
      .attr('width', 10)
      .attr('height', 10)

  assertStyles = (object, selector) ->
    unless object?
      assert(false, "Object contains no styles")

    unless (mapping = styleMap[selector])?
      assert(false, "Could not find styles with selector: #{selector}")

    for key, value of mapping
      assert.equal object[key], value, "Style mismatch on rule '#{key}'"

  before (done) ->
    makeStyleSheet()
    makeContainer()
    done()

  after (done) ->
    doc.head.removeChild(styleTag)
    doc.body.removeChild(container.node())
    done()

  describe 'getStyles', ->
    it 'should find styles for an svg element', ->
      styles = Epoch.QueryCSS.getStyles('rect', container)
      assertStyles styles, '#container rect'

    it 'should find styles using a specific class name', ->
      styles = Epoch.QueryCSS.getStyles('rect.a', container)
      assertStyles styles, '#container rect.a'

    it 'should find styles using an id', ->
      styles = Epoch.QueryCSS.getStyles('rect#byid', container)
      assertStyles styles, 'rect#byid'

  describe 'purge', ->
    before (done) ->
      d3.select(doc.body).attr('class', 'alt-color')
      done()

    after (done) ->
      d3.select(doc.body).attr('class', null)
      done()

    it 'should find cached styles before a purge', ->
      styles = Epoch.QueryCSS.getStyles('rect#byid', container)
      assertStyles styles, 'rect#byid'

    it 'should find new styles after purging the cache', ->
      Epoch.QueryCSS.purge()
      styles = Epoch.QueryCSS.getStyles('rect#byid', container)
      assertStyles styles, 'body.alt-color rect#byid'
