THREE = require('three')

###* 
* For now Geometry2d is simply a proxy for THREE.Shape
###
class Geometry2d extends THREE.Shape
  
  constructor:(points)->
    THREE.Shape.call @, points

  
module.exports = Geometry2d