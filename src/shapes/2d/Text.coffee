utils = require '../utils'
merge = utils.merge
Shape2d = require './shape2d'

###* 
* Construct a 2D text (extrudeable)
* @param {object} size: size of text (default 10)
* @param {string} font: font of text (default "helvetiker")
* @param {object} center: center of circle (default [0,0,0])
* @param {object} o: (orientation): vector towards wich the circle should be facing
* @param {int} $fn: (resolution) corner resolution
###
class Text extends Shape2d
  
  constructor:(options)->
    options = options or {}
    defaults = { text: "Hello coffee!", size:10, divisions:10, font:"helvetiker" }
    options = merge(defaults, options)
    
    @textShapes = THREE.FontUtils.generateShapes(options.text,options)
    ###      hash = document.location.hash.substr( 1 )
    if ( hash.length != 0 )
      theText = hash###
     
module.exports = Text