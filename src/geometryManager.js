module.exports = GeometryManager;

GeometryManager = function() {
	//manage instances of geometries
	this._geometries = {};
};

GeometryManager.prototype={
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



