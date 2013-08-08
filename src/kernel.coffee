'use strict'

AssetManager = require( "./assetManager")
GeometryManager = require( "./geometryManager")


Geometry2d = require("./geometry/2d/geometry2d")
Geometry3d = require("./geometry/3d/geometry3d")
THREE = require('three')

starPoints = []
starPoints.push( new THREE.Vector2( 0, 50 ) )
starPoints.push( new THREE.Vector2( 10,  10 ) )
starPoints.push( new THREE.Vector2( 40,  10 ) )
starPoints.push( new THREE.Vector2( 20, -10 ) )
starPoints.push( new THREE.Vector2( 30, -50 ) )
starPoints.push( new THREE.Vector2( 0, -20 ) )
starPoints.push( new THREE.Vector2( -30, -50 ) )
starPoints.push( new THREE.Vector2( -20, -10 ) )
starPoints.push( new THREE.Vector2( -40,  10 ) )
starPoints.push( new THREE.Vector2( -10,  10 ) )


geom2d = new Geometry2d(starPoints)
geom3d = new Geometry3d()

console.log("2d",geom2d)
console.log("3d",geom3d)

console.log THREE.Shape
 
extrusionSettings = {
    size: 30, height: 4, curveSegments: 3,
    bevelThickness: 1, bevelSize: 2, bevelEnabled: false,
    material: 0, extrudeMaterial: 1
}

console.log geom2d.getPoints()


geom2d.extrude(extrusionSettings)

starGeometry = new THREE.ExtrudeGeometry( geom2d, extrusionSettings )

### 
materialFront = new THREE.MeshBasicMaterial( { color: 0xffff00 } )
materialSide = new THREE.MeshBasicMaterial( { color: 0xff8800 } )
materialArray = [ materialFront, materialSide ]
starMaterial = new THREE.MeshFaceMaterial(materialArray)
###

#star = new THREE.Mesh( starGeometry, starMaterial )
console.log("extruded",starGeometry)



class Kernel
  constructor:(options)->
    options = options or {}
    
    @stores = {}
    #@assetManager = new AssetManager( @stores )
    @geometryManager = new GeometryManager()
    @slicer = null

  compile:( source )->
    source = source or ""

  export:( source , outformat )->
    source = source or ""
    outformat = outformat or "stl"

  #data management
  addStore:( store )->
    @stores[store.name] = store

  addParser:( parser )->
    @assetManager.addParser( parser )

  #slicing management
  setSlicer:( slicer )->
    @slicer = slicer



module.exports = Kernel
