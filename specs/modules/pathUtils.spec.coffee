'use strict'
pathUtils = require "../../src/modules/pathUtils"


describe "PathUtils", ->
  
  it 'can extract the store name of most uris',->
    obsStoreName = pathUtils.parseStoreName("/home/foo/bar")
    expStoreName = "local"
    expect(obsStoreName).toEqual( expStoreName )
    
    obsStoreName = pathUtils.parseStoreName("c:/MyDocuments/foo/bar")
    expStoreName = "local"
    expect(obsStoreName).toEqual( expStoreName )
    
    obsStoreName = pathUtils.parseStoreName("dummy:specs/femur.stl")
    expStoreName = "dummy"
    expect(obsStoreName).toEqual( expStoreName )
    
    obsStoreName = pathUtils.parseStoreName("https://raw.github.com/kaosat-dev/repBug/master/cad/stl/femur.stl")
    expStoreName = "xhr"
    expect(obsStoreName).toEqual( expStoreName )
    
    obsStoreName = pathUtils.parseStoreName("dropbox:OtherProject/someFile.coffee")
    expStoreName = "dropbox"
    expect(obsStoreName).toEqual( expStoreName )



