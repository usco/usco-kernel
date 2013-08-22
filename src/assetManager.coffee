'use strict'

###*
 *Manager for lifecyle of assets: external stl, amf, textures, fonts etc
*###
class AssetManager
  constructor: ->
  	#manages assets (files)
  	@loaders = {}
  	@_resourceMap = {}

  addParser: ( loader )->
		#add a parser

  loadResource: ( store, filename )->
    #load resource, store it in resource map
    extension = filename.split("/").pop()
    _resourceMap[filename] = store

  unLoadResource: ( store, filename )->
    #todo check references, lifecycle etc
	  
	  
module.exports = AssetManager


