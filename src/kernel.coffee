'use strict'

AssetManager = require "./assetManager"
GeometryManager = require "./geometryManager"
Compiler = require "./compiler/compiler"

class Kernel
  constructor:(options)->
    options = options or {}
    
    @stores = {}
    @assetManager = new AssetManager( @stores )
    @geometryManager = new GeometryManager()
    
    @compiler = new Compiler()
    @slicer = null

  compile:( source )->
    source = source or ""
  
  compileFile:( path )->
    path = path or ""
    
  compileProject:( project ) ->
    project = project or ""

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
