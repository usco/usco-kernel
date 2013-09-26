THREE = require 'three'

extrusion = require '../extrusion'
{linear,rotate,path} = extrusion.types
utils = require '../../utils'
merge = utils.merge

###* 
* For now Shape2d is simply a proxy for THREE.Shape
###
class Shape2d extends THREE.Shape
  
  constructor:(points)->
    THREE.Shape.call @, points
   
  #TODO: allow use of svg syntax ???
  
  extrude:(options)->
    defaults = {type:linear, amount: 5,  bevelEnabled: false, bevelSegments: 2, steps: 2}
    options = merge(defaults, options)
    
    linearExtrude = ( geometry2D, options ) ->
    ### 
    text3d = new THREE.ExtrudeGeometry( @textShapes, options )
    text3d.computeBoundingBox()
    text3d.computeVertexNormals()
    
    textMaterial = new THREE.MeshBasicMaterial( { color: Math.random() * 0xffffff})
    
    text3d = new ObjectBase( text3d, textMaterial )
    return text3d###

  
module.exports = Shape2d