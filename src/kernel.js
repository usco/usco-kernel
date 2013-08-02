
var AssetManager = require( "./assetManager")
var GeometryManager = require( "./geometryManager")

module.exports = kernel

function Kernel( options ) {
	if (!(this instanceof Kernel)) return new Kernel( options )
	var options = options or {}

	this.stores = {};
	this.assetManager = new AssetManager(  this.stores  );
	this.geometryManager = new GeometryManager();
	this.slicer = null;
}


Kernel.prototype = {

	constructor: Kernel
}

Kernel.prototype.compile = function( source="" )
{

}

Kernel.prototype.export = function( source="" , outformat="stl" )
{

}

//data management
Kernel.prototype.addStore = function( store )
{
	this.stores[ store.name ] = store;
}

Kernel.prototype.addParser = function( parser )
{
	this.assetManager.addParser( parser );
}

//slicing management
Kernel.prototype.setSlicer = function( slicer )
{
	this.slicer = slicer;
}

