distance = (A, B, C)->
  ABx = B.x-A.x
  ABy = B.y-A.y
  num = ABx*(A.y-C.y)-ABy*(A.x-C.x)
  if (num < 0)
    num = -num
  return num

pointLocation = ( A,  B,  P) ->
  cp1 = (B.x-A.x)*(P.y-A.y) - (B.y-A.y)*(P.x-A.x)
  if cp1>0
    return 1
  return -1

findFarthestPoint=(points, minPoint, maxPoint)->
  #max distance search
  maxDist = -Infinity
  maxDistPoint = null
  for point in points
    dist = distance(point, minPoint, maxPoint)#pointLineDist2(point, minPoint, maxPoint)
    if dist > maxDist
      maxDist = dist
      maxDistPoint = point
  return maxDistPoint
  
removePoints=(points, maxDistPoint, minPoint, maxPoint)->
  #Point exclusion
  result = points.slice(0)
  toRemove = []
  
  for i in [result.length - 1..0] by -1
    point = result[i]
    if pointInTriangle(point, maxDistPoint, minPoint, maxPoint)
      toRemove.push(point)
      #result.remove(point)    
      result=removeFromArray(result, point)
  #console.log "removed points:"
  #console.log toRemove
  return result  

getLeftAndRighSets = (points, minPoint, maxPoint)->
  #divide into two sets of points : on the left and right from the line created by minPoint->maxPoint
  rightSet = []
  leftSet = []
  for point in points
    cross = sign(point,minPoint,maxPoint)
    if cross < 0 #left
      leftSet.push(point)
    else if cross > 0 #right
      rightSet.push(point)
    #we leave out anything on the line (cross ==0)
  return [leftSet, rightSet]
  
quickHullSub3 = (points) ->
  convexHull = []
  if points.length < 3
    return points
  #--------------------------------------
  #Find first two points on the convex hull (min, max)
  minPoint = {x:+Infinity,y:0}
  maxPoint = {x:-Infinity,y:0}  
  for point in points
      if point.x < minPoint.x
        minPoint = point
      if point.x > maxPoint.x
        maxPoint = point
  convexHull.push(minPoint)
  convexHull.push(maxPoint)
  removeFromArray(points, minPoint)
  removeFromArray(points, maxPoint)
  #--------------------------------------
  #divide into two sets of points : on the left and right from the line created by minPoint->maxPoint
  [rightSet,leftSet] = getLeftAndRighSets(points, minPoint, maxPoint)
  hullSet(minPoint, maxPoint, rightSet, convexHull)
  hullSet(maxPoint, minPoint, leftSet, convexHull)
  
  return convexHull

hullSet = (minPoint, maxPoint, set, hull)->  
  insertPosition = hull.indexOf(maxPoint)
  if (set.length == 0)
    return
  if (set.length == 1) 
    p = set[0]
    removeFromArray(set, p)
    hull.splice(insertPosition, 0, p)
    return
  furthestPoint = findFarthestPoint(set, minPoint, maxPoint)
  hull.splice(insertPosition, 0, furthestPoint)
  
  [rightSet,leftSet] = getLeftAndRighSets(set, minPoint, furthestPoint)
  [rightSet2,leftSet2] = getLeftAndRighSets(set, furthestPoint, maxPoint)
  
  hullSet(minPoint, furthestPoint, rightSet, hull)
  hullSet(furthestPoint, maxPoint, rightSet2, hull)
        
convexHull2D = (geom) ->
  #quickhull hull implementation experiment
  #see here http://westhoffswelt.de/blog/0040_quickhull_introduction_and_php_implementation.html/
  geoms= undefined
  if geom instanceof Array
    geoms = geom
  else
    geoms = [geom]

  #TODO: sort all points for optimising
  points = []
  posIndex= []
  
  posExists = (pos)->
    index = "#{pos._x}#{pos._y}"
    if posIndex.indexOf(index) == -1
      posIndex.push index
      return false
    return true
           
  geoms.map (geom) ->
    for side in geom.sides
      v0Pos = side.vertex0.pos
      v1Pos = side.vertex1.pos
      #remove redundant positions
      if not posExists(v0Pos)
        points.push(v0Pos)
      if not posExists(v1Pos)
        points.push(v1Pos)
  
  hullPoints = quickHullSub3(points)
  #console.log("ENDRESULT POINTS: Length#{hullPoints.length}, points:\n #{hullPoints}")
  #console.log "finalHullPoints:\n #{hullPoints}"
  result = CAGBase.fromPoints(hullPoints)
  result


###* 
 * 3d implementation of convex hull based on three.js version
 * @author qiao / https://github.com/qiao
 * @fileoverview This is a convex hull generator using the incremental method. 
 * The complexity is O(n^2) where n is the number of vertices.
 * O(nlogn) algorithms do exist, but they are much more complicated.
 *
 * Benchmark: 
 *
 *  Platform: CPU: P7350 @2.00GHz Engine: V8
 *
 *  Num Vertices  Time(ms)
 *
 *     10           1
 *     20           3
 *     30           19
 *     40           48
 *     50           107
 ###


class ConvexHull3D extends THREE.Geometry
  constructor:( vertices )->
    @vertices = vertices
    faces = [ [ 0, 1, 2 ], [ 0, 2, 1 ] ]

    for vertex,index in vertices
      @addPoint( index )  

  addPoint:( vertexId ) ->
    vertex = @vertices[ vertexId ].clone()
    mag = vertex.length()
    vertex.x += mag * randomOffset()
    vertex.y += mag * randomOffset()
    vertex.z += mag * randomOffset()

    hole = []
    for ( f = 0 f < faces.length )
      face = faces[ f ]

      #for each face, if the vertex can see it,
      #then we try to add the face's edges into the hole.
      if ( @visible( face, vertex ) )
        for ( e = 0 e < 3 e++ )
          edge = [ face[ e ], face[ ( e + 1 ) % 3 ] ]
          boundary = true
          #remove duplicated edges.
          for ( h = 0 h < hole.length h++ )
            if ( equalEdge( hole[ h ], edge ) )
              hole[ h ] = hole[ hole.length - 1 ]
              hole.pop()
              boundary = false
              break
          if ( boundary )
            hole.push( edge )

        #remove faces[ f ]
        faces[ f ] = faces[ faces.length - 1 ]
        faces.pop()
      else #not visible
        f++
        
    #construct the new faces formed by the edges of the hole and the vertex
    for h in [0...hole.length]
      faces.push( [ 
        hole[ h ][ 0 ],
        hole[ h ][ 1 ],
        vertexId
      ] )

  ###*
   * Whether the face is visible from the vertex
  ###
  visible:( face, vertex ) ->
    va = vertices[ face[ 0 ] ]
    vb = vertices[ face[ 1 ] ]
    vc = vertices[ face[ 2 ] ]

    n = normal( va, vb, vc )

    #distance from face to origin
    dist = n.dot( va )

    return n.dot( vertex ) >= dist 

  ###*
   * Face normal
  ###
  normal: ( va, vb, vc ) ->

    cb = new THREE.Vector3()
    ab = new THREE.Vector3()

    cb.subVectors( vc, vb )
    ab.subVectors( va, vb )
    cb.cross( ab )

    cb.normalize()

    return cb


  ###*
   * Detect whether two edges are equal.
   * Note that when constructing the convex hull, two same edges can only
   * be of the negative direction.
    ###
  equalEdge:( ea, eb ) ->
    return ea[ 0 ] === eb[ 1 ] && ea[ 1 ] === eb[ 0 ] 

  ###*
   * Create a random offset between -1e-6 and 1e-6.
    ###
  randomOffset: ->
    return ( Math.random() - 0.5 ) * 2 * 1e-6

  ###*
   * XXX: Not sure if this is the correct approach. Need someone to review.
   ###
  vertexUv:( vertex ) ->
    mag = vertex.length()
    return new THREE.Vector2( vertex.x / mag, vertex.y / mag )

  #Push vertices into `this.vertices`, skipping those inside the hull
  id = 0
  newId = new Array( vertices.length ) #map from old vertex id to new id

  for ( i = 0 i < faces.length i++ ) {

     face = faces[ i ]

     for ( j = 0 j < 3 j++ ) {

        if ( newId[ face[ j ] ] === undefined ) {

            newId[ face[ j ] ] = id++
            this.vertices.push( vertices[ face[ j ] ] )

        }

        face[ j ] = newId[ face[ j ] ]

     }

  }

  #Convert faces into instances of THREE.Face3
  for ( i = 0 i < faces.length i++ ) {

    this.faces.push( new THREE.Face3( 
        faces[ i ][ 0 ],
        faces[ i ][ 1 ],
        faces[ i ][ 2 ]
    ) )

  }

  #Compute UVs
  for ( i = 0 i < this.faces.length i++ )
    face = this.faces[ i ]

    this.faceVertexUvs[ 0 ].push( [
      vertexUv( this.vertices[ face.a ] ),
      vertexUv( this.vertices[ face.b ] ),
      vertexUv( this.vertices[ face.c ])
    ] )

  this.computeCentroids()
  this.computeFaceNormals()
  this.computeVertexNormals()


hull(geometry) ->
  #wrapper method for convexHull2d, convexHull3d
  #test if geometry is 2d or 3d , switch accordingly

module.exports = hull