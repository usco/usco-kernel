Shape2d = require './shape2d'

###* 
* Construct a 2D Rectangle
* @param {object} size: scalar or vector 
* @param {object} center: center of circle (default [0,0,0])
* @param {object} o: (orientation): vector towards wich the circle should be facing
* @param {int} $fn: (resolution) determines the resolution of corner roundings
###
class Rectangle extends Shape2d
  # Parameters:
  #   center: center of rectangle (default [0,0,0])
  #   size : 2D vector or scalar
  # 
  constructor:(options)->
    options = options or {}
    defaults = { size:[1,1], center:[0,0,0], o:[0,0,0] , $fn:1 }
    
    size = options.size or defaults.size

    shape = new THREE.Shape()

    shape = new THREE.Shape()
    shape.moveTo( 0,0 )
    shape.lineTo( 0, size[0] )
    shape.lineTo( size[1], size[0] )
    shape.lineTo( size[1], 0 )
    shape.lineTo( 0, 0 )
  
    points = shape.createPointsGeometry()
    spacedPoints = shape.createSpacedPointsGeometry( 100 )
    geometry = new THREE.ShapeGeometry( shape )
    
    super( geometry )

module.exports = Rectangle
        