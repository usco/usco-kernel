'use strict'
optParse = require("../../src/shapes/optParse")
THREE = require( 'three' )


describe "parse param to 3d vector", ->
  toVec3 = optParse.parseParamAs3dVector
  
  it 'defaults to a 3d vector with all components set to 0', ->
    param = null 
    vec3 = toVec3( param )
    expect( vec3 ).toEqual( new THREE.Vector3( 0,0,0 ) )
  
  it 'can set the 3d vector using a default value', ->
    param = null 
    vec3 = toVec3( param , new THREE.Vector3( 1,15,-7 ) )
    expect( vec3 ).toEqual( new THREE.Vector3( 1,15,-7 ) )
  
  it 'can parse arrays of length 3 to 3d vector', ->
    param = [1,15,-7] 
    vec3 = toVec3( param )
    expect( vec3 ).toEqual( new THREE.Vector3( 1,15,-7 ) )
  
  it 'can parse arrays of length 2 to 3d vector', ->
    param = [1,15] 
    vec3 = toVec3( param )
    expect( vec3 ).toEqual( new THREE.Vector3( 1,15,1 ) )
  
  it 'can parse arrays of length 1 to 3d vector', ->
    param = [1] 
    vec3 = toVec3( param )
    expect( vec3 ).toEqual( new THREE.Vector3( 1,1,1 ) )
  
  it 'can parse scalars to 3d vector', ->
    param = 15
    vec3 = toVec3( param )
    expect( vec3 ).toEqual( new THREE.Vector3( 15,15,15 ) )

describe "parse param to 2d vector", ->
  toVec2 = optParse.parseParamAs2dVector
  
  it 'defaults to a 2d vector with all components set to 0', ->
    param = null
    vec2 = toVec2( param )
    #expect( vec2 ).toEqual( new THREE.Vector2( 0,0 ) )
  
  ###
  it 'can set the 2d vector using a default value', ->
    param = null 
    vec3 = toVec2( param , new THREE.Vector2( 1,15) )
    expect( vec2 ).toEqual( new THREE.Vector2( 1,15 ) )
  
  it 'can parse arrays of length 2 to 2d vector', ->
    param = [1,15] 
    vec2 = toVec2( param )
    expect( vec2 ).toEqual( new THREE.Vector2( 1,15) )
  
  it 'can parse arrays of length 1 to 2d vector', ->
    param = [1] 
    vec2 = toVec2( param )
    expect( vec2 ).toEqual( new THREE.Vector2( 1,1,1 ) )
  
  it 'can parse scalars to 3d vector', ->
    param = 15
    vec2 = toVec2( param )
    expect( vec2 ).toEqual( new THREE.Vector2( 15,15 ) )
  ###
### 
describe "Options parsing utilities", ->
  
  beforeEach ->
  
  it 'has a centerParser, no input (should default to false)', ->
    options = {}
    size = new THREE.Vector3(10)
    parsed = utils.parseCenter(options,"center",size.dividedBy(2), [0,0,0], THREE.Vector3)
    expCenter = new THREE.Vector3(5,5,5)
    expect(parsed).toEqual(expCenter)
  
  it 'has a centerParser, vector input', ->
    options = {"center":[0,0,5]}
    size = new THREE.Vector3(10)
    parsed = utils.parseCenter(options,"center",size.dividedBy(2), [0,0,0], THREE.Vector3)
    expCenter = new THREE.Vector3(0,0,5)
    expect(parsed).toEqual(expCenter)
  
  it 'has a centerParser, single boolean, false', ->
    options = {"center":false}
    size = new THREE.Vector3(10)
    parsed = utils.parseCenter(options,"center",size.dividedBy(2), [0,0,0], THREE.Vector3)
    expCenter = new THREE.Vector3(5)
    expect(parsed).toEqual(expCenter)
    
  it 'has a centerParser, single boolean, true', ->
    options = {"center":true}
    size = new THREE.Vector3(10)
    parsed = utils.parseCenter(options,"center",size.dividedBy(2), [0,0,0], THREE.Vector3)
    expCenter = new THREE.Vector3(0)
    expect(parsed).toEqual(expCenter)
    
  it 'has a centerParser, boolean array , all true', ->
    options = {"center":[true,true,true]}
    size = new THREE.Vector3(10)
    parsed = utils.parseCenter(options,"center",size.dividedBy(2), [0,0,0], THREE.Vector3)
    expCenter = new THREE.Vector3(0)
    expect(parsed).toEqual(expCenter)
  
  
  it 'has a centerParser, boolean array , all false', ->
    options = {"center":[false,false,false]}
    size = new THREE.Vector3(10)
    parsed = utils.parseCenter(options,"center",size.dividedBy(2), [0,0,0], THREE.Vector3)
    expCenter = new THREE.Vector3(5)
    expect(parsed).toEqual(expCenter)
    
  it 'has a centerParser, boolean array , first false', ->
    options = {"center":[false,true,true]}
    size = new THREE.Vector3(10)
    parsed = utils.parseCenter(options,"center",size.dividedBy(2), [0,0,0], THREE.Vector3)
    expCenter = new THREE.Vector3(5,0,0)
    expect(parsed).toEqual(expCenter)
  
  it 'has a centerParser, boolean array , first & second false', ->
    options = {"center":[false,false,true]}
    size = new THREE.Vector3(10)
    parsed = utils.parseCenter(options,"center",size.dividedBy(2), [0,0,0], THREE.Vector3)
    expCenter = new THREE.Vector3(5,5,0)
    expect(parsed).toEqual(expCenter)
  
  it 'has a centerParser, boolean array , second & last false', ->
    options = {"center":[true,false,false]}
    size = new THREE.Vector3(10)
    parsed = utils.parseCenter(options,"center",size.dividedBy(2), [0,0,0], THREE.Vector3)
    expCenter = new THREE.Vector3(0,5,5)
    expect(parsed).toEqual(expCenter)
  
  it 'has a centerParser, boolean and float array var1', ->
    options = {"center":[3,false,false]}
    size = new THREE.Vector3(10)
    parsed = utils.parseCenter(options,"center",size.dividedBy(2), [0,0,0], THREE.Vector3)
    expCenter = new THREE.Vector3(3,5,5)
    expect(parsed).toEqual(expCenter)
    
  it 'has a centerParser, boolean and float array var2', ->
    options = {"center":[3,true,2]}
    size = new THREE.Vector3(10)
    parsed = utils.parseCenter(options,"center",size.dividedBy(2), [0,0,0], THREE.Vector3)
    expCenter = new THREE.Vector3(3,0,2)
    expect(parsed).toEqual(expCenter)  

  
  it 'has a locationsParser', ->
    
    options = {"corners":["left"]}
    parsed = utils.parseOptionAsLocations(options,"corners","111111")
    expBitMap = "111011".toString(2)
    expect(parsed).toEqual(expBitMap)
    
    options = {"corners":["right"]}
    parsed = utils.parseOptionAsLocations(options,"corners","111111")
    expBitMap = "110111".toString(2)
    expect(parsed).toEqual(expBitMap)
    
    options = {"corners":["top"]}
    parsed = utils.parseOptionAsLocations(options,"corners","111111")
    expBitMap = "101111".toString(2)
    expect(parsed).toEqual(expBitMap)
    
    options = {"corners":["bottom"]}
    parsed = utils.parseOptionAsLocations(options,"corners","111111")
    expBitMap = "11111".toString(2)
    expect(parsed).toEqual(expBitMap)
    
    options = {"corners":["right","left"]}
    parsed = utils.parseOptionAsLocations(options,"corners","111111")
    expBitMap = "111111".toString(2)
    expect(parsed).toEqual(expBitMap)
    
    options = {"corners":["top","bottom"]}
    parsed = utils.parseOptionAsLocations(options,"corners","111111")
    expBitMap = "111111".toString(2)
    expect(parsed).toEqual(expBitMap)
    
    options = {"corners":["top right"]}
    parsed = utils.parseOptionAsLocations(options,"corners","111111")
    expBitMap = "100111".toString(2)
    expect(parsed).toEqual(expBitMap)
    
    options = {"corners":["top left"]}
    parsed = utils.parseOptionAsLocations(options,"corners","111111")
    expBitMap = "101011".toString(2)
    expect(parsed).toEqual(expBitMap)
    
    options = {"corners":["bottom right"]}
    parsed = utils.parseOptionAsLocations(options,"corners","111111")
    expBitMap = "10111".toString(2)
    expect(parsed).toEqual(expBitMap)
    
    options = {"corners":["bottom left"]}
    parsed = utils.parseOptionAsLocations(options,"corners","111111")
    expBitMap = "11011".toString(2)
    expect(parsed).toEqual(expBitMap)
    
    options = {"corners":["left front"]}
    parsed = utils.parseOptionAsLocations(options,"corners","111111")
    expBitMap = "111010".toString(2)
    expect(parsed).toEqual(expBitMap)
    
    options = {"corners":["right front"]}
    parsed = utils.parseOptionAsLocations(options,"corners","111111")
    expBitMap = "110110".toString(2)
    expect(parsed).toEqual(expBitMap)
    
    options = {"corners":["left back"]}
    parsed = utils.parseOptionAsLocations(options,"corners","111111")
    expBitMap = "111001".toString(2)
    expect(parsed).toEqual(expBitMap)
    
    options = {"corners":["right back"]}
    parsed = utils.parseOptionAsLocations(options,"corners","111111")
    expBitMap = "110101".toString(2)
    expect(parsed).toEqual(expBitMap)
    
    #FULL
    options = {"corners":["top right front"]}
    parsed = utils.parseOptionAsLocations(options,"corners","111111")
    expBitMap = "100110".toString(2)
    expect(parsed).toEqual(expBitMap)
    
    options = {"corners":["top right back"]}
    parsed = utils.parseOptionAsLocations(options,"corners","111111")
    expBitMap = "100101".toString(2)
    expect(parsed).toEqual(expBitMap)
    
    options = {"corners":["top left front"]}
    parsed = utils.parseOptionAsLocations(options,"corners","111111")
    expBitMap = "101010".toString(2)
    expect(parsed).toEqual(expBitMap)
    
    options = {"corners":["top left back"]}
    parsed = utils.parseOptionAsLocations(options,"corners","111111")
    expBitMap = "101001".toString(2)
    expect(parsed).toEqual(expBitMap)
    
    options = {"corners":["bottom right front"]}
    parsed = utils.parseOptionAsLocations(options,"corners","111111")
    expBitMap = "10110".toString(2)
    expect(parsed).toEqual(expBitMap)
    
    options = {"corners":["bottom right back"]}
    parsed = utils.parseOptionAsLocations(options,"corners","111111")
    expBitMap = "10101".toString(2)
    expect(parsed).toEqual(expBitMap)
    
    options = {"corners":["bottom left front"]}
    parsed = utils.parseOptionAsLocations(options,"corners","111111")
    expBitMap = "11010".toString(2)
    expect(parsed).toEqual(expBitMap)
    
    options = {"corners":["bottom left back"]}
    parsed = utils.parseOptionAsLocations(options,"corners","111111")
    expBitMap = "11001".toString(2)
    expect(parsed).toEqual(expBitMap)
    
    #even more complex
    #options = {"corners":["bottom left back","top right front" ]}
    #parsed = utils.parseOptionAsLocations(options,"corners","111111")
    #expBitMap = "11001".toString(2)
    #expect(parsed).toEqual(expBitMap)
###