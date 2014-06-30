# Singelton class used to query CSS styles by way of reference elements.
# This allows canvas based visualizations to use the same styles as their
# SVG counterparts.
class QueryCSS
  # Reference container id
  REFERENCE_CONTAINER_ID = '_canvas_css_reference'

  # Container Hash Attribute
  CONTAINER_HASH_ATTR = 'data-epoch-container-id'

  # Handles automatic container id generation
  containerCount = 0
  nextContainerId = -> "epoch-container-#{containerCount++}"

  # Expression used to derive tag name, id, and class names from
  # selectors given the the put method.
  PUT_EXPR = /^([^#. ]+)?(#[^. ]+)?(\.[^# ]+)?$/

  # Whether or not to log full selector lists
  logging = false

  # Converts selectors into actual dom elements (replaces put.js)
  # Limited the functionality to what Epoch actually needs to
  # operate correctly. We detect class names, ids, and element
  # tag names.
  put = (selector) ->
    match = selector.match(PUT_EXPR)
    return Epoch.error('Query CSS cannot match given selector: ' + selector) unless match?
    [whole, tag, id, classNames] = match
    tag = (tag ? 'div').toUpperCase()

    element = document.createElement(tag)
    element.id = id.substr(1) if id?
    if classNames?
      element.className = classNames.substr(1).replace(/\./g, ' ')

    return element

  # Lets the user set whether or not to log selector lists and resulting DOM trees. 
  # Useful for debugging QueryCSS itself.
  @log: (b) ->
    logging = b

  # Key-Value cache for computed styles that we found using this class.
  @cache = {}

  # List of styles to pull from the full list of computed styles
  @styleList = ['fill', 'stroke', 'stroke-width']

  # The svg reference container
  @container = null

  # Purges the selector to style cache
  @purge: ->
    QueryCSS.cache = {}

  # Gets the reference element container.
  @getContainer: ->
    return QueryCSS.container if QueryCSS.container?
    container = document.createElement('DIV')
    container.id = REFERENCE_CONTAINER_ID
    document.body.appendChild(container)
    QueryCSS.container = d3.select(container)

  # @return [String] A unique identifier for the given container and selector.
  # @param [String] selector Selector from which to derive the styles
  # @param container The containing element for a chart.
  @hash: (selector, container) ->
    containerId = container.attr(CONTAINER_HASH_ATTR)
    unless containerId?
      containerId = nextContainerId()
      container.attr(CONTAINER_HASH_ATTR, containerId)
    return "#{containerId}__#{selector}"

  # @return The computed styles for the given selector in the given container element.
  # @param [String] selector Selector from which to derive the styles.
  # @param container HTML containing element in which to place the reference SVG.
  @getStyles: (selector, container) ->
    # 0) Check for cached styles
    cacheKey = QueryCSS.hash(selector, container)
    cache = QueryCSS.cache[cacheKey]
    return cache if cache?

    # 1) Build a full reference tree (parents, container, and selector elements)
    parents = []
    parentNode = container.node().parentNode

    while parentNode? and parentNode.nodeName.toLowerCase() != 'body'
      parents.unshift parentNode
      parentNode = parentNode.parentNode
    parents.push container.node()

    selectorList = []
    for element in parents
      sel = element.nodeName.toLowerCase()
      if element.id? and element.id.length > 0
        sel += '#' + element.id
      if element.className? and element.className.length > 0
        sel += '.' + Epoch.Util.trim(element.className).replace(/\s+/g, '.')
      selectorList.push sel

    selectorList.push('svg')

    for subSelector in Epoch.Util.trim(selector).split(/\s+/)
      selectorList.push(subSelector)

    console.log(selectorList) if logging

    parent = root = put(selectorList.shift())
    while selectorList.length
      el = put(selectorList.shift())
      parent.appendChild el
      parent = el

    console.log(root) if logging

    # 2) Place the reference tree and fetch styles given the selector
    QueryCSS.getContainer().node().appendChild(root)

    ref = d3.select('#' + REFERENCE_CONTAINER_ID + ' ' + selector)
    styles = {}
    for name in QueryCSS.styleList
      styles[name] = ref.style(name)
    QueryCSS.cache[cacheKey] = styles

    # 3) Cleanup and return the styles
    QueryCSS.getContainer().html('')
    return styles


Epoch.QueryCSS = QueryCSS