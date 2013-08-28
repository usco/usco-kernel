ObjectBase = require '../shapes/base'

###*** 
*Base class for defining "parts"
###
class Part extends ObjectBase
  constructor:(options)->
    super options
    parent = @__proto__.__proto__.constructor.name
    #register(@__proto__.constructor.name, @, options)
    defaults = {manufactured:true}
    options = merge defaults, options
    
    #should this be even here ?
    @manufactured = options.manufactured
    
module.exports = Part