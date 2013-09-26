ObjectBase = require '../base'
Constants = require '../constants'

###* 
* Construct a solid Sphere
* @param {float} r: radius of sphere (default 1), must be a scalar: alternative: d (see below)
* @param {float} d: diameter of sphere (default 0.5), must be a scalar: alternative: r (see above)
* @param {object} center: center of sphere (default [0,0,0])
* @param {object} o: (orientation): vector towards wich the sphere should be facing
* @param {float} angle1: angle along first axis (allows to create a portion of sphere instead of a full sphere) (default:360)
* @param {float} angle2: angle along second axis (allows to create a portion of sphere instead of a full sphere) (default:360)
* @param {float} angle3: angle along third axis (allows to create a portion of sphere instead of a full sphere) (default:360)
* @param {int} $fn: (resolution) determines the number of polygons per 360 degree revolution (default 12)
* @param {bool} icosa: (optional): if true, the sphere will actually be an icosahedron (default true)
###
class Sphere extends ObjectBase
  constructor:(options)->
    options = options or {}
    defaults = { r:1, d:0.5, center:[0,0,0], o:[0,0,0], angle1:360, angle2:360, angle3:360, $fn:Constants.res3D, icosa:true }
    
    r = options.r or 1
    $fn = options.$fn or $fn
    icosa = options.icosa or true
    console.log "r", r , "$fn", $fn, "ico", icosa
    
    if icosa
      geometry = new THREE.SphereGeometry( r, $fn, $fn )
    else
      geometry = new THREE.IcosahedronGeometry( r, $fn )
      
    super( geometry )

module.exports = Sphere