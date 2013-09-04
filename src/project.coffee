'use strict'

Compiler = require './compiler'


class Folder extends Backbone.Collection
  model: ProjectFile
  sync : null
  constructor:(options)->
    super options
    @_storageData = []

  save:=>
    for index, file of @models
      file.sync = @sync
      file.save() 
    
  changeStorage:(storeName,storeData)->
    for oldStoreName in  @_storageData
      delete @[oldStoreName]
    @_storageData = []  
    @_storageData.push(storeName)
    @[storeName] = storeData
    for index, file of @models
      file.sync = @sync 
      #file.pathRoot= project.get("name")


###Main aspect of coffeescad : contains all the files
  * project is a top level element ("folder" + metadata)
  * a project contains files 
  * a project can reference another project (includes)
###
class Project 
  persistedAttributeNames : ['name','lastModificationDate']
  
  constructor:(options)->
    options = options or {}
    
    
    @name = "Project"
    @lastModificationDate: null
    
    @activeFile = null
    @isSaveAdvised = false #based on propagation from project files : if a project file is changed, the project is tagged as "dirty" aswell
    @isCompiled = false
    @isCompileAdvised = false
    
    
    @compiler = options.compiler ? new Compiler()
    
    @rootFolder = new Folder()
    @rootFolder.on("reset",@_onFilesReset)
    
    classRegistry={}
    @bom = new Backbone.Collection()
    @rootAssembly = {}
    @dataStore = null
    
    @rootPath = ""
    #
    @fileNames = []
    
    @on("change:name", @_onNameChanged)
    @on("compiled",@_onCompiled)
    @on("compile:error",@_onCompileError)
    @on("loaded",@_onFilesReset)
    
  addFile:(options)->
    file = new ProjectFile
      name: options.name ? @name+".coffee"
      content: options.content ? " \n\n"
    @_addFile(file)   
    return file
    
  removeFile:(file)=>
    @rootFolder.remove(file)
    @isSaveAdvised = true
  
  save: (attributes, options)=>
    #project is only a container, if really necessary data could be stored inside the metadata file (.project)
    @dataStore.saveProject(@)
    @_clearFlags()
    @trigger("save", @)
    
  compile:(options)=>
    if not @compiler?
      throw new Error("No compiler specified")
    @compiler.project = @
    return @compiler.compile(options)
  
  injectContent:(content, fileName)=>
    #add content (code to either the main, or a specific file)
    if not fileName?
      fileName = @rootFolder.get(@name+".coffee")
    
    file = @rootFolder.get(fileName)  
    file.content += content
  
  makeFileActive:(options)=>
    #set the currently active file (only one at a time)
    #you could argue that this is purely UI side, in fact it is not : events, adding data to the file etc should use the currently active
    #file, therefore there is logic , not just UI , but the UI should reflect this
    options = options or {}
    fileName = null
    
    if options instanceof String or typeof options is 'string' 
      fileName = options
    if options instanceof ProjectFile 
      fileName = options.name
    if options.file
      fileName = options.file.name
    if options.fileName
      fileName = options.fileName
      
    file = @rootFolder.get(fileName)  
    if file?
      file.isActive = true
      @activeFile =file
      #DESELECT ALL OTHERS   
      otherFiles = _.without(@rootFolder.models, file) 
      for otherFile in otherFiles
        otherFile.isActive=false
    return @activeFile
    
  _addFile:(file)=>
    @rootFolder.add file
    @_setupFileEventHandlers(file)
    @isSaveAdvised = true
  
  _setupFileEventHandlers:(file)=>
    file.on("change:content",@_onFileChanged)
    file.on("save",@_onFileSaved)
    file.on("destroy",@_onFileDestroyed)
    
  _clearFlags:=>
    #used to reset project into a "neutral" state (no save and compile required)
    for file in @rootFolder.models
      file.isSaveAdvised = false
      file.isCompileAdvised = false
    @isSaveAdvised = false
    @isCompileAdvised = false
    
  _onCompiled:=>
    @compiler.project = null
    @isCompileAdvised = false
    for file in @rootFolder.models
      file.isCompileAdvised = false
    @isCompiled = true
    
  _onCompileError:=>
    @compiler.project = null
    @isCompileAdvised = false
    for file in @rootFolder.models
      file.isCompileAdvised = false
    @isCompiled = true
    
  _onNameChanged:(model, name)=>
    try
      mainFile = @rootFolder.get(@previous('name')+".coffee")
      if mainFile?
        console.log "project name changed from #{@previous('name')} to #{name}"
        mainFile.name = "#{name}.coffee"
    catch error
      console.log "error in rename : #{error}"
  
  _onFilesReset:()=>
    #add various event bindings, reorder certain specific files
    mainFileName ="#{@name}.coffee"
    ### 
    mainFile = @rootFolder.get(mainFileName)
    @rootFolder.remove(mainFileName)
    @rootFolder.add(mainFile, {at:0})
    
    configFileName = "config.coffee"
    configFile = @rootFolder.get(configFileName)
    @rootFolder.remove(configFileName)
    @rootFolder.add(configFile, {at:1})
    ###
    console.log "files reset, setting active file to",mainFileName
    @makeFileActive({fileName:mainFileName})
    
    for file in @rootFolder.models
      @_setupFileEventHandlers(file)
      
    @_clearFlags()
  
  _onFileSaved:(fileName)=>
    @lastModificationDate = new Date()
    for file of @rootFolder
      if file.isSaveAdvised
        return
    
  _onFileChanged:(file)=>
    @isSaveAdvised = file.isSaveAdvised if file.isSaveAdvised is true
    @isCompileAdvised = file.isCompileAdvised if file.isCompileAdvised is true
  
  _onFileDestroyed:(file)=>
    if @dataStore
      @dataStore.destroyFile(@name, file.name)
    
module.exports = Project
