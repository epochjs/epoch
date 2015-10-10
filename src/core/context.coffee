# Rendering context used for unit testing.
class Epoch.TestContext
  VOID_METHODS = [
    'arc', 'arcTo', 'beginPath', 'bezierCurveTo', 'clearRect',
    'clip', 'closePath', 'drawImage', 'fill', 'fillRect', 'fillText',
    'moveTo', 'quadraticCurveTo', 'rect', 'restore', 'rotate', 'save',
    'scale', 'scrollPathIntoView', 'setLineDash', 'setTransform',
    'stroke', 'strokeRect', 'strokeText', 'transform', 'translate', 'lineTo'
  ]

  # Creates a new test rendering context.
  constructor: ->
    @_log = []
    @_makeFauxMethod(method) for method in VOID_METHODS

  # Creates a fake method with the given name that logs the method called
  # and arguments passed when executed.
  # @param name Name of the fake method to create.
  _makeFauxMethod: (name) ->
    @[name] = -> @_log.push "#{name}(#{(arg.toString() for arg in arguments).join(',')})"

  # Faux method that emulates the "getImageData" method
  getImageData: ->
    @_log.push "getImageData(#{(arg.toString() for arg in arguments).join(',')})"
    return { width: 0, height: 0, resolution: 1.0, data: [] }
