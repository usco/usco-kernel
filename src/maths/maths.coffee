use 'strict'
THREE = require 'THREE'

###*
  *All classes , functions etc defined here are simple wrappers, to make "logical" namespacing
  *easier (ie Maths.Vector2 instead of THREE.Vector2), and to add a level of indirection between api and implementation
  * 
###

###* 
* 3d vector class: simple wrapper around THREE.Vector3 + some additional params parsing helpers
###
class Vector3 extends THREE.Vector3
  constructor:( options )->
    super(options)

class Vector2 extends THREE.Vector2
  constructor:( options )->
    super(options)

#lines, curves
class Spline extends THREE.Spline
  constructor:( options )->
    super(options)
    
class SplineCurve3 extends THREE.SplineCurve3

class ArcCurve extends THREE.ArcCurve

#TODO: unify bezier curve types under common api
class CubicBezierCurve3 extends THREE.CubicBezierCurve3

class QuadraticBezierCurve3 extends THREE.QuadraticBezierCurve3

#other
class Euler extends THREE.Euler
  constructor:( options )->
    super(options)

module.exports = 
  Vector2: Vector2
  Vector3: Vector3
  Spline3: SplineCurve3
  Euler : Euleur
  