
  /*
  @author kaosat-dev 
  resulting js will be cleaned up , and contributed to three.js
  */
  var THREE;
  THREE = require('three');
  THREE.stlExporter = function() {};
  THREE.stlExporter.prototype = {
    constructor: THREE.stlExporter,

    _generateString: function(geometry) {
      /* 
        facet normal ni nj nk
          outer loop
              vertex v1x v1y v1z
              vertex v2x v2y v2z
              vertex v3x v3y v3z
          endloop
        endfacet
      */

      var face, facetData, facets, header, i, index, j, normal, normalData, vertex, vertexIndices, vertices, verticesData, _i, _j, _k, _len, _ref, _ref1, _ref2;
      header = "solid geometry.name \n";
      vertices = [];
      _ref = geometry.vertices;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        vertex = _ref[_i];
        vertices;
      }
      facets = [];
      _ref1 = geometry.faces;
      for (index in _ref1) {
        face = _ref1[index];
        facetData = "facet ";
        normal = face.normal;
        normalData = "normal " + normal.x + " " + normal.y + " " + normal.z + "\n";
        vertexIndices = [];
        if (face instanceof THREE.Face3) {
          vertexIndices[0] = [face.a, face.b, face.c];
        } else if (face instanceof THREE.Face4) {
          vertexIndices[0] = [face.a, face.b, face.c];
          vertexIndices[1] = [face.c, face.d, face.a];
        }
        verticesData = "";
        for (i = _j = 0, _ref2 = vertexIndices.length; 0 <= _ref2 ? _j < _ref2 : _j > _ref2; i = 0 <= _ref2 ? ++_j : --_j) {
          verticesData += facetData + normalData;
          verticesData += "  outer loop\n";
          for (j = _k = 0; _k < 3; j = ++_k) {
            vertex = geometry.vertices[vertexIndices[i][j]];
            verticesData += "    vertex " + (vertex.x.toPrecision(7)) + " " + (vertex.y.toPrecision(7)) + " " + (vertex.z.toPrecision(7)) + "\n";
          }
          verticesData += "  endloop\n" + "endfacet\n";
        }
        facetData = verticesData;
        facets.push(facetData);
      }
      return header + facets.join("");
    },

    _generateBinary: function(geometry) {
      var ar1, arindex, attribDataArray, blobData, buffer, face, headerarray, i, index, int32buffer, int8buffer, normal, numtriangles, numvertices, pos, v, vertexDataArray, vv, _i, _j, _k, _ref, _ref1;
      blobData = [];
      buffer = new ArrayBuffer(4);
      int32buffer = new Int32Array(buffer, 0, 1);
      int8buffer = new Int8Array(buffer, 0, 4);
      int32buffer[0] = 0x11223344;
      if (int8buffer[0] !== 0x44) {
        throw new Error("Binary STL output is currently only supported on little-endian (Intel) processors");
      }
      numtriangles = 0;
      this.currentObject.faces.map(function(face) {
        var numvertices, thisnumtriangles;
        numvertices = face.vertices.length;
        thisnumtriangles = numvertices >= 3 ? numvertices - 2 : 0;
        return numtriangles += thisnumtriangles;
      });
      headerarray = new Uint8Array(80);
      for (i = _i = 0; _i < 80; i = ++_i) {
        headerarray[i] = 65;
      }
      blobData.push(headerarray);
      ar1 = new Uint32Array(1);
      ar1[0] = numtriangles;
      blobData.push(ar1);
      _ref = geometry.faces;
      for (index in _ref) {
        face = _ref[index];
        numvertices = face.vertices.length;
        for (i = _j = 0, _ref1 = numvertices - 2; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
          vertexDataArray = new Float32Array(12);
          normal = face.normal;
          vertexDataArray[0] = normal.x;
          vertexDataArray[1] = normal.y;
          vertexDataArray[2] = normal.z;
          arindex = 3;
          for (v = _k = 0; _k < 3; v = ++_k) {
            vv = v + (v > 0 ? i : 0);
            pos = face.vertices[vv].pos;
            vertexDataArray[arindex++] = pos.x;
            vertexDataArray[arindex++] = pos.y;
            vertexDataArray[arindex++] = pos.z;
          }
          attribDataArray = new Uint16Array(1);
          attribDataArray[0] = 0;
          blobData.push(vertexDataArray);
          blobData.push(attribDataArray);
        }
      }
      return blobData;
    },
    parse: function(geometry) {
      console.log(geometry);
      return this._generateString(geometry);
    }
};


