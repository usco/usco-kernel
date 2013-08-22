'use strict'

AssetManager = require( "./assetManager")
GeometryManager = require( "./geometryManager")

Geometry2d = require("./geometry/2d/geometry2d")
Geometry3d = require("./geometry/3d/geometry3d")


class Kernel
  constructor:(options)->
    options = options or {}
    
    @stores = {}
    @assetManager = new AssetManager( @stores )
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
