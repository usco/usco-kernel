
#FROM COFFEESCRIPT HELPERS
merge = ( options, overrides ) ->
  extend (extend {}, options), overrides

extend = ( object, properties ) ->
  for key, val of properties
    object[key] = val
  object
  
#TODO: how to handle these kind of things : not part of globals on NODE , but ok in browsers?
btoa = (str) ->
  buffer = undefined
  if str instanceof Buffer
    buffer = str
  else
    buffer = new Buffer(str.toString(), "binary")
  buffer.toString "base64"

module.exports.merge = merge
module.exports.extend = extend
module.exports.btoa = btoa

