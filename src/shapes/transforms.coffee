use 'strict'

utils = require './utils'
toVector3 = utils.parseParamAs3dVector

###* 
* translate object(s) by amount
* @param {array,vector3} amount: can be of type vector3, array (1d, 2d, 3d), or scalar (same as 1d array):
* actual transformation is computed based on raw value of amount
* @param {object, array} objects:  one ore more objects to translate
* translation order : x,y,z
###
translate = ( amount, objects...)->
  amount = toVector3( amount )
  
  for object in objects
    object.translate( amount )

###* 
* rotate object(s) by amount
* @param {array,vector3} amount: can be of type vector3, array (1d, 2d, 3d), or scalar (same as 1d array):
* actual transformation is computed based on raw value of amount
* @param {object, array} objects:  one ore more objects to rotate
* rotation order : x,y,z
###
rotate = ( amount, objects...)->
  amount = toVector3( amount )
  
  for object in objects
    object.rotate( amount )


###* 
* scale object(s) by amount
* @param {array,vector3} amount: can be of type vector3, array (1d, 2d, 3d), or scalar (same as 1d array):
* actual transformation is computed based on raw value of amount
* @param {object, array} objects:  one ore more objects to rotate
* scale order : x,y,z
* #TODO: scale is a bit different from the other transforms as it transforms the geometry , not just the assembly node
###
scale = ( amount, objects...)->
  amount = toVector3( amount )
  
  for object in objects
    object.rotate( amount )

###* 
* mirror object(s) using given direction vector
* @param {vector3} direction: direction in which to apply mirroring :
* unit vector or if not, converted to unit vector (0->0 >0 -> 1 <0 ->-1
* @param {object, array} objects:  one ore more objects to mirror
* mirror order : x,y,z
###
mirror = ( amount, objects...)->
  amount = toVector3( amount )
  
  for object in objects
    object.mirror( amount )

module.exports.translate = tanslate
module.exports.rotate = rotate
module.exports.scale = scale
module.exports.mirror = mirror