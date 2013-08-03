'use strict'

#manage instances of geometries
class GeometryManager
  constructor:()->
    @_geometries = {}

  registerGeometry: (geometry)->
    @_geometries[geometry.uuid] = geometry

  unRegisterGeometry: (geometry)->
    index = @_geometries.indexOf(geometry)
    if (index != -1)
      @_geometries.splice(index, 1)

  ongeometryChanged: (geometry)->
    #if geometry has changed, it needs to be allocated to a different "slot"
    registerGeometry( geometry )

module.exports = GeometryManager



