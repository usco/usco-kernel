use 'strict'
THREE = require 'THREE'

###*
  *All classes , functions etc defined here are simple wrappers, to make "logical" namespacing
  *easier (ie Maths.Vector2 instead of THREE.Vector2), and to add a level of indirection between api and implementation
  * 
###

###* 
* 3d vector class: simple wrapper around THREE.Vector3 + some additional params parsing helpers
###
class Vector3 extends THREE.Vector3
  constructor:( options )->
    super(options)

class Vector2 extends THREE.Vector2
  constructor:( options )->
    super(options)

module.exports = 
  Vector2: Vector2
  Vector3: Vector3
  