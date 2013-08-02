var Kernel = require ("coscad-kernel");

Store = function() {
	//slice em up !
	this.name = "dbStore";
	Kernel.addStore( this );
};

Store.prototype={
	constructor: Store,
	
	saveProject: function( project )
	{
		//do cool stuff
	}

	loadProject: function( project )
	{
		//do cool stuff
	}
};
