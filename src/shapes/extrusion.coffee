THREE = require('three')

linear = "L"
rotate = "R"
path   = "P"


###* 
* Basic "straigth line" extrusion of 2d shape
* with optional "twist"
###
linearExtrude = ( geometry2D, options ) ->
  extrusionSettings = {
    size: 30, height: 4, curveSegments: 3,
    bevelThickness: 1, bevelSize: 2, bevelEnabled: false,
    material: 0, extrudeMaterial: 1
  }
  geometry3D = new THREE.ExtrudeGeometry( geometry2D, extrusionSettings )
  return geometry3D

###* 
* Rotated extrusion of 2d shape
###
rotateExtrude = ( geometry2D, options ) ->

###* 
* Spline/bezier curve based extrusion of 2d shape : the 2d shape is extuded along the given spline
* allow creation from points or directly from curve
### 
pathExtrude = ( geometry2D, options ) ->
  extrusionSettings = {
    size: 30, height: 4, curveSegments: 3,
    bevelThickness: 1, bevelSize: 2, bevelEnabled: false,
    material: 0, extrudeMaterial: 1
  }
  
  #usage example
  splinePath = new THREE.SplineCurve3()
  splinePath.points.push(new THREE.Vector3(-50, 150, 10))
  splinePath.points.push(new THREE.Vector3(-20, 180, 20))
  splinePath.points.push(new THREE.Vector3(40, 220, 50))
  splinePath.points.push(new THREE.Vector3(200, 290, 100))
  
  extrusionSettings.extrudePath = splinePath
  
  geometry3D = new THREE.ExtrudeGeometry( geometry2D, extrusionSettings )
  return geometry3D
  

module.exports.linearExtrude = linearExtrude
module.exports.rotateExtrude = rotateExtrude
module.exports.pathExtrude   = pathExtrude
module.exports.types = {linear:linear,rotate:rotate,path:path}
