'use strict'

fs = require("fs")
path = require("path")

AssetManager = require "../../src/assetManager"
CModule = require "../../src/io/cModule"
File = require "../../src/io/file"

DummyStore = require "../dummyStore"
DummyXHRStore = require "../dummyXHRStore"
STLParser = require "../STLParser"  

describe "CModule", ->
  stores = []
  assetManager = null
  
  
  beforeEach ->
    stores["dummy"] = new DummyStore()
    stores["xhr"] = new DummyXHRStore()
    
    assetManager = new AssetManager( stores )
    assetManager.addParser("stl", STLParser)

  it 'grants user defined code access to predefined api/core modules (maths, shapes etc)', (done)->
    source = """
    shape = new shapes.Cube()
    assembly.add(shape)
    
    shape2 = new shapes.Cube();
    vect = new maths.Vector3();
    vect2 = new Vector3(5,10,-7);
    """
    # module.exports.shape = shape
    #module.exports.shape2 = shape2
    module = new CModule("dummy:specs/data/main.coffee", source)
    #module.generateExports = false
    #console.log "module", CModule.coreModules
    
    module.assetManager = assetManager #dependency injection, a bit weird ass : TODO: creating modules might be better done by factory that injects this??
    module.doAll()
    .then ( exports ) =>
      expect(Object.keys( exports )).toEqual( [ 'shape', 'shape2', 'vect', 'vect2' ] )
      done()
    .fail (error) =>
      expect(false).toBeTruthy error.message
      done()
    

  it 'handles all necessary pre-processing',(done)->
    source = """

#include("dummy:specs/data/test.coffee")
#include("./anotherTest.coffe")
otherModuleResult = include("./test.coffee")

console.log "include result", otherModuleResult

foo = otherModuleResult + 42

try
  subGeom3 = importGeom("dummy:specs/data/pointedStick.stl")
  console.log "bla", subGeom3
catch error
  console.log "error", error

exports = module.exports = foo
    """
    #import toto from "tata"
    module = new CModule("dummy:specs/data/main.coffee", source)
    module.assetManager = assetManager #dependency injection, a bit weird ass : TODO: creating modules might be better done by factory that injects this??
    module.doAll()
    .then ( exports ) =>
      expect( exports ).toEqual ( 287 )
      console.log("exports", exports)
      done()
    .fail (error) =>
      expect(false).toBeTruthy error.message
      done()
  , 10000
  
  it 'auto adds root elements to module exports', (done)->
    source = """
variableToExport = 42
    """
    
    module = new CModule("dummy:specs/data/main.coffee", source)
    module.assetManager = assetManager #dependency injection, a bit weird ass : TODO: creating modules might be better done by factory that injects this??
    module.doAll()
    .then ( exports ) =>
      expect( exports ).toEqual ( { variableToExport : 42 }  )
      done()
    .fail (error) =>
      expect(false).toBeTruthy error.message
      done()

  it 'auto adds root elements to module exports only when there are no manually defined exports ', (done)->
    source = """
variableToExport = 42
module.exports.variableToExport = 76
    """
    
    module = new CModule("dummy:specs/data/main.coffee", source)
    module.assetManager = assetManager #dependency injection, a bit weird ass : TODO: creating modules might be better done by factory that injects this??
    module.doAll()
    .then ( exports ) =>
      expect( exports ).toEqual ( { variableToExport : 76 }  )
      done()
    .fail (error) =>
      expect(false).toBeTruthy error.message
      done()

  it 'handles geometry data imports, as if imports where sync', (done)->
    source = """
loadedGeometry = importGeom("./cube.stl")
module.exports = loadedGeometry
    """
    expData = fs.readFileSync( path.resolve( "./specs/data/cube.stl" ), 'utf8' )
    expData = assetManager.parsers["stl"].parse( expData )
    expData.id = 1 #since three.js id are auto incremented, force a false id
    
    module = new CModule("dummy:specs/data/main.coffee", source)
    module.assetManager = assetManager #dependency injection, a bit weird ass : TODO: creating modules might be better done by factory that injects this??
    module.doAll()
    .then ( exports ) =>
      exports.id = 1  #since three.js id are auto incremented, force a false id
      expect( exports ).toEqual ( expData )
      done()
    .fail (error) =>
      expect(false).toBeTruthy error.message
      done()

  it 'handles geometry data import errors as if they where sync, re-raising error at compile time', (done)->
    source = """
loadedGeometry = importGeom("./unknown.stl")
module.exports = loadedGeometry
    """
    expError = new Error( "Error: specs/data/unknown.stl not found" )
    
    module = new CModule("dummy:specs/data/main.coffee", source)
    module.assetManager = assetManager #dependency injection, a bit weird ass : TODO: creating modules might be better done by factory that injects this??
    module.doAll()
    .then ( exports ) =>
      expect(false).toBeTruthy error.message
      done()
    .fail (error) =>
      expect(error).toEqual( expError )
      done()
