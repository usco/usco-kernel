Shape2d = require './shape2d'

###* 
* Construct a 2D Circle
* @param {float} r: radius of sphere (default 1), must be a scalar: alternative: d (see below)
* @param {float} d: diameter of sphere (default 0.5), must be a scalar: alternative: r (see above)
* @param {object} center: center of circle (default [0,0,0])
* @param {object} o: (orientation): vector towards wich the circle should be facing
* @param {int} $fn: (resolution) determines the number of polygons per 360 degree revolution (default 12)
###
class Circle extends Shape2d

  constructor:(options)->
    options = options or {}
    defaults = { r:1, d:0.5, center:[0,0,0] ,o:[0,0,0] $fn:1 }
    
    circleRadius = options.r or 1
    $fn = options.$fn or $fn

    shape = new THREE.Shape()
    ### 
    shape.moveTo( 0, circleRadius )
    shape.quadraticCurveTo( circleRadius, circleRadius, circleRadius, 0 )
    shape.quadraticCurveTo( circleRadius, -circleRadius, 0, -circleRadius )
    shape.quadraticCurveTo( -circleRadius, -circleRadius, -circleRadius, 0 )
    shape.quadraticCurveTo( -circleRadius, circleRadius, 0, circleRadius )
    ###
    
    shape.absarc( 0, 0, circleRadius, 0, Math.PI+0.1, false )
    
    points = shape.createPointsGeometry()
    spacedPoints = shape.createSpacedPointsGeometry( 100 )
    #geometry = new THREE.ShapeGeometry( shape )
    
    #super( geometry )

module.exports = Circle