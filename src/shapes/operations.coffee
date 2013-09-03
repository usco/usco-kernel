use 'strict'

###* 
 * experimental : classes acting as container for transforms etc : to be used in transforms histories
 * and object manipulations
###

class Operation

  toString:=>
    return ""

class Translate extends Operation
  constructor:( amount )->
    super()
    @tVector = amount
    
  toString:=>
    return  "T:"+@tVector 

class Rotate extends Operation
  constructor:( amount )->
    super()
    @rVector = amount
    
  toString:=>
    return  "R:"+@rVector 
    

class Scale extends Operation
  constructor:( amount )->
    super()
    @sVector = amount
    
  toString:=>
    return  "S:"+@sVector 
    
module.exports.Operation = Operation
module.exports.Translate = Translate
module.exports.Rotate = Rotate
module.exports.Scale = Scale
