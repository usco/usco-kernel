
#FROM COFFEESCRIPT HELPERS
merge = ( options, overrides ) ->
  extend (extend {}, options), overrides

extend = ( object, properties ) ->
  for key, val of properties
    object[key] = val
  object

module.exports.merge = merge
module.exports.extend = extend

