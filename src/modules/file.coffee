'use strict'

class File
  persistedAttributeNames : ['name','content']
    
  constructor:( name, content )->
    @name = name or "testFile.coffee"
    @content = content or ""
    
    #keep these?
    @isActive = false
    @isSaveAdvised = false
    @isCompileAdvised = false
    #@loaded = false
    
    #This is used for "dirtyness compare" , might be optimisable (storage vs time , hash vs direct compare)
    @storedContent = @content
    #@on("save",   @_onSaved)
    #@on("change:name", @_onNameChanged)
    #@on("change:content", @_onContentChanged)
    #@on("change:isActive",@_onIsActiveChanged)
  
  _onNameChanged:()=>
    @isSaveAdvised = true

  _onContentChanged:()=>
    @isCompileAdvised = true
    if (@storedContent is @content)
      @isSaveAdvised = false
    else
      @isSaveAdvised = true
      
  _onSaved:()=>
    #when save is sucessfull
    @storedContent = @content
    @isSaveAdvised = false
    
  _onIsActiveChanged:=>
    if @isActive
      @trigger("activated")
    else
      @trigger("deActivated")
 
  save: (attributes, options)=>
    backup = @toJSON
    @toJSON= =>
      attributes = _.clone(@attributes)
      for attrName, attrValue of attributes
        if attrName not in @persistedAttributeNames
          delete attributes[attrName]
      return attributes
     
    super attributes, options 
    @toJSON=backup
    @trigger("save",@)
   
   destroy:(options)=>
    options = options or {}
    @trigger('destroy', @, @collection, options)

module.exports = File  