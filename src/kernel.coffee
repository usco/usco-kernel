'use strict'

AssetManager = require( "./assetManager")
GeometryManager = require( "./geometryManager")


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


kernelInstance = null

module.exports = {
    getInstance: (options) =>
        return kernelInstance if kernelInstance?
        return new Kernel( options )
}

