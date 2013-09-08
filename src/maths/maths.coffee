use 'strict'

###* 
* 3d vector class: simple wrapper around THREE.Vector3 + some additional params parsing helpers
###
class Vector3 extends THREE.Vector3
  constructor:( options )->
    super(options)

module.exports = Vector3