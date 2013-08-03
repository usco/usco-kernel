//manager for lifecyle of assets: external stl, amf, textures, fonts etc

AssetManager = function() {
	//manages assets (files)
	this._resourceMap = {};
	this.loaders = {};
};

AssetManager.prototype={
	constructor: AssetManager,

	addParser: function (loader)
	{
		//add a parser
	},

	loadResource: function( store, filename )
	{
		var extension = filename.split("/").pop();
		_resourceMap
	},

	unLoadResource: function( store, filename )
	{
	}

};

