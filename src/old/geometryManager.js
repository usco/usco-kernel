

function GeometryManager() {
	//manage instances of geometries
	this._geometries = {};
	console.log("gne");
};

GeometryManager.prototype = {
	constructor: GeometryManager,

	registerGeometry: function(geometry)
	{
		this._geometries[geometry.uuid] = geometry;
	},

	unRegisterGeometry: function(geometry)
	{
		var index = this._geometries.indexOf(geometry);
		if (index !== -1)
		{
			this._geometries.splice(index, 1);
		}
	},

	ongeometryChanged: function(geometry)
	{
		//if geometry has changed, it needs to be allocated to a different "slot"
		registerGeometry( geometry );
	}
};

module.exports = GeometryManager;



