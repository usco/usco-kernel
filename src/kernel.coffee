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

  ###* 
  * compile source and export to the specified formats
  * @param {string} source: source to export
  * @param {object, array} outputUris:  one ore more uris (store + fileName WITH extension) to export to
  * @param {object, array} params: parameters to pass to the exports: should be a hash, with the key being the format ie stl-> params etc
  ###
  export:( source , outputUris..., exportParams )->
    source = source or ""
    if outputUris.length is 0
      throw new Error("No output paths(s) specified")
    
    compiled = @compile( source )
    for outputUri in  outputUris 
      storeName = ""
      filePath = ""
      format = "stl"
      #outformat = outformat or "stl"
      #first get data
      #data = @exporters[ format ].export()
      #then export to given storage
      @stores[ storeName ].writeFile( data, filePath )


  #data management
  addStore:( store )->
    @stores[store.name] = store

  addParser:( parser )->
    @assetManager.addParser( parser )

  addExporter:( exporter )->
  

  #slicing management
  setSlicer:( slicer )->
    @slicer = slicer


module.exports = Kernel
