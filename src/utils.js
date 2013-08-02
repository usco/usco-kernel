
merge = function(options, overrides) {
	return extend(extend({}, options), overrides);
};

 extend = function(object, properties) {
	var key, val;
	for (key in properties) {
  		val = properties[key];
  		object[key] = val;
	}
	return object;
};

module.exports.merge = merge
module.exports.extend = extend

