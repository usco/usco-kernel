ObjectBase = require '../base'
Constants = require '../constants'

#TODO: not yet implemented
###* 
* Construct a solid Torus
* @param {float} r: radius of sphere (default 1), must be a scalar: alternative: d (see below)
* @param {float} d: diameter of torus (default 0.5), must be a scalar: alternative: r (see above)
* @param {object} center: center of torus (default [0,0,0])
* @param {object} o: (orientation): vector towards wich the torus should be facing
* @param {float} angle1: angle along first axis (allows to create a portion of torus instead of a full torus) (default:360)
* @param {float} angle2: angle along second axis (allows to create a portion of torus instead of a full torus) (default:360)
* @param {float} angle3: angle along third axis (allows to create a portion of torus instead of a full torus) (default:360)
* @param {int} $fn: (resolution) determines the number of polygons per 360 degree revolution (default 12)
* @param {bool} icosa: (optional): if true, the torus will actually be an icosahedron (default true)
###
class Torus extends ObjectBase
  constructor:(options)->
    options = options or {}
    defaults = { r:1, d:0.5, center:[0,0,0], o:[0,0,0], angle1:360, angle2:360, angle3:360, $fn:Constants.res3D, icosa:true }
    
    r = options.r or 1
    $fn = options.$fn or $fn
    icosa = options.icosa or true
    console.log "r", r , "$fn", $fn, "ico", icosa
    
      
    super( geometry )

module.exports = Torus