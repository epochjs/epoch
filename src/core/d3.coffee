# Gets the width of the first node, or sets the width of all the nodes
# in a d3 selection.
# @param value [Number, String] (optional) Width to set for all the nodes in the selection.
# @return The selection if setting the width of the nodes, or the width
#   in pixels of the first node in the selection.
d3.selection::width = (value) ->
  if value? and Epoch.isString(value)
    @style('width', value)
  else if value? and Epoch.isNumber(value)
    @style('width', "#{value}px")
  else
    +Epoch.Util.getComputedStyle(@node(), null).width.replace('px', '')

# Gets the height of the first node, or sets the height of all the nodes
# in a d3 selection.
# @param value (optional) Height to set for all the nodes in the selection.
# @return The selection if setting the height of the nodes, or the height
#   in pixels of the first node in the selection.
d3.selection::height = (value) ->
  if value? and Epoch.isString(value)
    @style('height', value)
  else if value? and Epoch.isNumber(value)
    @style('height', "#{value}px")
  else
    +Epoch.Util.getComputedStyle(@node(), null).height.replace('px', '')