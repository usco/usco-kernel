require('three');


parseOptions = function(options, defaults) {
    var index, indexToName, key, name, option, result, val, _i, _len;
    if (Object.getPrototypeOf(options) === Object.prototype) {
      options = merge(defaults, options);
    } else if (options instanceof Array) {
      indexToName = {};
      result = {};
      index = 0;
      for (key in defaults) {
        if (!__hasProp.call(defaults, key)) continue;
        val = defaults[key];
        indexToName[index] = key;
        result[key] = val;
        index++;
      }
      for (index = _i = 0, _len = options.length; _i < _len; index = ++_i) {
        option = options[index];
        if (option != null) {
          name = indexToName[index];
          result[name] = option;
        }
      }
      options = result;
    }
    return options;
};

parseOption = function(options, optionname, defaultvalue) {
    var result;
    result = defaultvalue;
    if (options ? optionname in options : void 0) {
      result = options[optionname];
    }
    return result;
};

parseOptionAs3DVector = function(options, optionname, defaultValue, defaultValue2) {
    var doCenter, result;
    if (optionname in options) {
      if (options[optionname] === false || options[optionname] === true) {
        doCenter = parseOptionAsBool(options, optionname, false);
        if (doCenter) {
          options[optionname] = defaultValue;
        } else {
          options[optionname] = defaultValue2;
        }
      }
    }
    result = parseOption(options, optionname, defaultValue);
    if (result instanceof Array) {
      if (result.length === 3) {
        result = new THREE.Vector3(result[0], result[1], result[2]);
      } else if (result.length === 2) {
        result = new THREE.Vector3(result[0], result[1], 1);
      } else if (result.length === 1) {
        result = new THREE.Vector3(result[0], 1, 1);
      }
    } else if (result instanceof THREE.Vector3) {
      result = result;
    } else {
      result = new THREE.Vector3(result, result, result);
    }
    return result;
};

parseOptionAs2DVector = function(options, optionname, defaultValue, defaultValue2) {
    var doCenter, result;
    if (optionname in options) {
      if (options[optionname] === false || options[optionname] === true) {
        doCenter = parseOptionAsBool(options, optionname, false);
        if (doCenter) {
          options[optionname] = defaultValue;
        } else {
          options[optionname] = defaultValue2;
        }
      }
    }
    result = parseOption(options, optionname, defaultValue);
    result = new THREE.Vector2(result);
    return result;
};

parseOptionAsFloat = function(options, optionname, defaultvalue) {
	var result;
	result = parseOption(options, optionname, defaultvalue);
	if (typeof result === "string") {
  		result = Number(result);
	} else {
  		if (typeof result !== "number") {
    		throw new Error("Parameter " + optionname + " should be a number");
  		}
	}
	return result;
};

parseOptionAsInt = function(options, optionname, defaultvalue) {
	var result;
	result = parseOption(options, optionname, defaultvalue);
	return Number(Math.floor(result));
};

parseOptionAsBool = function(options, optionname, defaultvalue) {
    var result;
    result = parseOption(options, optionname, defaultvalue);
    if (typeof result === "string") {
      if (result === "true") {
        result = true;
      }
      if (result === "false") {
        result = false;
      }
      if (result === 0) {
        result = false;
      }
    }
    result = !!result;
    return result;
};

parseOptionAsLocations = function(options, optionName, defaultValue) {
    var loc, location, locations, mapping, mapping_old, result, stuff, subStuff, _i, _j, _len, _len1;
    result = parseOption(options, optionName, defaultValue);
    mapping_old = {
      "top": globals.top,
      "bottom": globals.bottom,
      "left": globals.left,
      "right": globals.right,
      "front": globals.front,
      "back": globals.back
    };
    mapping = {
      "all": parseInt("111111", 2),
      "top": parseInt("101111", 2),
      "bottom": parseInt("011111", 2),
      "left": parseInt("111011", 2),
      "right": parseInt("110111", 2),
      "front": parseInt("111110", 2),
      "back": parseInt("111101", 2)
    };
    stuff = null;
    for (_i = 0, _len = result.length; _i < _len; _i++) {
      location = result[_i];
      location = location.replace(/^\s+|\s+$/g, "");
      locations = location.split(" ");
      subStuff = null;
      for (_j = 0, _len1 = locations.length; _j < _len1; _j++) {
        loc = locations[_j];
        loc = mapping[loc];
        if (subStuff == null) {
          subStuff = loc;
        } else {
          subStuff = subStuff & loc;
        }
      }
      if (stuff == null) {
        stuff = subStuff;
      } else {
        stuff = stuff | subStuff;
      }
    }
    return stuff.toString(2);
};

  parseCenter = function(options, optionname, defaultValue, defaultValue2, vectorClass) {
    var centerOption, component, doCenter, index, newDefaultValue, newDefaultValue2, result, _i, _len;
    if (optionname in options) {
      centerOption = options[optionname];
      if (centerOption instanceof Array) {
        newDefaultValue = new vectorClass(defaultValue);
        newDefaultValue2 = new vectorClass(defaultValue2);
        for (index = _i = 0, _len = centerOption.length; _i < _len; index = ++_i) {
          component = centerOption[index];
          if (typeof component === 'boolean') {
            if (index === 0) {
              centerOption[index] = component === true ? newDefaultValue2.x : component === false ? newDefaultValue.x : centerOption[index];
            } else if (index === 1) {
              centerOption[index] = component === true ? newDefaultValue2.y : component === false ? newDefaultValue.y : centerOption[index];
            } else if (index === 2) {
              centerOption[index] = component === true ? newDefaultValue2.z : component === false ? newDefaultValue.z : centerOption[index];
            }
          }
        }
        options[optionname] = centerOption;
      } else {
        if (typeof centerOption === 'boolean') {
          doCenter = parseOptionAsBool(options, optionname, false);
          if (doCenter) {
            options[optionname] = defaultValue2;
          } else {
            options[optionname] = defaultValue;
          }
        }
      }
    }
    result = parseOption(options, optionname, defaultValue);
    result = new vectorClass(result);
    return result;
  };
