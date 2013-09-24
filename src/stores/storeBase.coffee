'use strict'
  
utils = require '../utils'
merge = utils.merge

###*
Base class for store : need to extend this for actual use

*###
class StoreBase
  
  constructor:(options)->
    #pubsubModule : in our case, appVent or any other backbone.marionette vent, but could be ANY non backbone pubsub system as well
    defaults = {enabled:true, pubSubModule: null, name:"store", shortName:"", type:"", description: "Store base class", rootUri:"", loggedIn:true, isLoginRequired:false,
    isDataDumpAllowed: false,showPaths:false}
    options = merge defaults, options
    {@enabled, @pubSubModule, @name, @shortName, @type, @description, @rootUri, @loggedIn, @isLoginRequired} = options
    
    @cachedProjectsList = []
    @cachedProjects = {}
    
    @fs = require('./fsBase')
    
  login:=>
    @loggedIn = true
      
  logout:=>
    @loggedIn = false
  
  setup:()->
    #do authentification or any other preliminary operation
    if @pubSubModule?
      if @isLoginRequired
        @pubSubModule.on("#{@type}:login", @login)
        @pubSubModule.on("#{@type}:logout", @logout)
  
  tearDown:()->
    #tidily shut down this store: is this necessary ? as stores have the same lifecycle as
    #the app itself ?
  
  #TODO: all the project related stuff is TOO specific, would need to be extracted to somewhere else
  saveProject:( project, path )=> 
    console.log "saving project to #{@type}"
    project.dataStore = @
    #also save metadata
    project.addOrUpdateMetaFile()
    
    if path?
      projectUri = path
      project.uri = projectUri
      targetName = @fs.basename( path )
      if targetName != project.name
        project.name = targetName
    else
      projectUri = project.uri
      #projectUri = @fs.join([@rootUri, project.name])
    
  ###Possible updated (simplified) api###
  list:( uri )->#get
  
  read:( uri )->#get
  
  write:( data, uri )->#put
    
  move:( uri, newuri)->#copy + delete///rename
  
  delete:( uri )->#delete
  
  ###-------------Helpers ----------------------------###
  getThumbNail:( projectName )=>
    
  spaceUsage: ->
    return {total:0, used:0, remaining:0, usedPercent:0}
 
  #replace spaceUsage with accountInfo?   
  
  ###--------------Private methods---------------------###
  _dispatchEvent:(eventName, data)=>
    if @pubSubModule?
      @pubSubModule.trigger(eventName, data)
    else
      throw new Error( "no pubsub system specified, cannot dispatch event" )
     
module.exports = StoreBase