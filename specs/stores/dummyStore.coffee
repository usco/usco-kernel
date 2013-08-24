StoreBase = require "../src/store/storeBase"

class DummyStore extends StoreBase
  constructor:(options) ->
	  options = options or {}
	  defaults = {enabled: (if process? then true else false) ,name:"node", shortName:"node", type:"nodeStore",
	  description: "Dummy/testing store",
    rootUri:if process? then process.env.HOME or process.env.HOMEPATH or process.env.USERPROFILE else null,
    isDataDumpAllowed: false,showPaths:true}
	  
	  options = merge defaults, options
	  super options
	  
	  #@fs = new NodeFS()
	  kernel = options.kernel
    Kernel.addStore( @ )


