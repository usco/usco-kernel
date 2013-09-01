THREE = require( 'three' )
ThreeCSG =  require( '../../vendor/ThreeCSG' )
  
#TODO: where to do canonicalization and normalization?
#TODO: review inheritance : basic geometry (cube, sphere) should not have children etc (like "mesh") but should have position, rotation etc
#TODO: add connectors

class ObjectBase extends THREE.Mesh
  #base class regrouping features of THREE.Mesh and THREE.CSG
  
  constructor:( geometry, material )->
    if not material?
      material = new THREE.MeshBasicMaterial( { color: 0xffffff, wireframe: false } )
      shine= 1500
      spec= 1000
      opacity = 1
      material = new THREE.MeshPhongMaterial({color:  0xFFFFFF , shading: THREE.SmoothShading,  shininess: shine, specular: spec, metal: false}) 
    #super(geometry, material)
    THREE.Mesh.call( @, geometry, material )
    
    
    #VERY important : transforms stack : all operations done on this shape is stored here
    #TODO: should we be explicit , ie in basic shape class, or do it in processor/preprocessor
    @transforms = []
    
    
    #FIXME: see THREE.jS constructors thingamajig
    #console.log @prototype
    #Object.create(@prototype)
    @bsp = null
    
    @connectors = []
  
  #------base transforms--------#
  translate:( amount )->
    tVector = toVector3( amount )
    
    #TODO: work around these, for more efficiency)
    @translateX( tVector.x )
    @translateY( tVector.y )
    @translateZ( tVector.z )
    
    #TODO: add actual data structures for this
    @transforms.push( "T:"+tVector )
    
  rotate:( amount )->
    rVector = toVector3( amount )
    euler = new THREE.Euler( rVector.x, rVector.y, rVector.z)
    
    @setRotationFromEuler( euler )
    
    #TODO: add actual data structures for this
    @transforms.push( "R:"+rVector )
  
  #------retro compatibility------#
  color:(rgba)->
    @material.color = rgba
    
  #------CSG Methods------#
  union:(object)=>
    @bsp = new ThreeBSP(@)
    if not object.bsp?
      object.bsp = new ThreeBSP(object)
    @bsp = @bsp.union( object.bsp )
    #TODO : only generate geometry on final pass ie make use of csg tree or processing tree/ast
    @geometry = @bsp.toGeometry()
    @geometry.computeVertexNormals()
    
  subtract:(object)=>
    @bsp = new ThreeBSP(@)
    
    object.bsp = new ThreeBSP(object)
    @bsp = @bsp.subtract( object.bsp )
    #TODO : only generate geometry on final pass ie make use of csg tree or processing tree/ast
    @geometry = @bsp.toGeometry()
    @geometry.computeVertexNormals()
    
    @geometry.computeBoundingBox()
    @geometry.computeCentroids()
    @geometry.computeFaceNormals();
    @geometry.computeBoundingSphere()
    
  intersect:=>
    @bsp = @bsp.intersect( object.bsp )
    #TODO : only generate geometry on final pass ie make use of csg tree or processing tree/ast
    @geometry = @bsp.toGeometry()
    @geometry.computeVertexNormals()
    
  inverse:=>
    @bsp = @bsp.invert()
    #TODO : only generate geometry on final pass ie make use of csg tree or processing tree/ast
    @geometry = @bsp.toGeometry()
    @geometry.computeVertexNormals()
  
module.exports = ObjectBase