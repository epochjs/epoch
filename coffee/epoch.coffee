window.Epoch ?= {}
window.Epoch.Chart ?= {}
window.Epoch.Time ?= {}
window.Epoch.Util ?= {}
window.Epoch.Formats ?= {}

# Sends a warning to the developer console with the given message.
# @param [String] msg Message for the warning.
Epoch.warn = (msg) ->
  (console.warn or console.log)("Epoch Warning: #{msg}")

# Raises an exception with the given message (with the 'Epoch Error:' preamble).
# @param [String] msg Specific message for the exception.
Epoch.exception = (msg) ->
  throw "Epoch Error: #{msg}"

# "I think, baby, I was born just a little late!" -- Middle Class Rut
