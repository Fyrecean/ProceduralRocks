extends MeshInstance3D

func gen_icosahedron(radius: float = 1, subdiv: int = 0) -> Mesh:
	var gold = Vector2((1+sqrt(5))/4, .5).normalized() * radius
	
	var verts = PackedVector3Array([
		Vector3(gold.x, gold.y, 0), Vector3(gold.x, -gold.y, 0), Vector3(-gold.x, -gold.y, 0), Vector3(-gold.x, gold.y, 0),
		Vector3(0, gold.x, gold.y), Vector3(0, gold.x, -gold.y), Vector3(0, -gold.x, -gold.y), Vector3(0, -gold.x, gold.y),
		Vector3(gold.y, 0, gold.x), Vector3(gold.y, 0, -gold.x), Vector3(-gold.y, 0, -gold.x), Vector3(-gold.y, 0, gold.x)
	])
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array[Mesh.ARRAY_VERTEX] = PackedVector3Array(verts)
	surface_array[Mesh.ARRAY_INDEX] = PackedInt32Array([
		0,8,4,
		0,5,9,
		0,4,5,
		0,9,1,
		0,1,8,
		11,4,8,
		11,8,7,
		11,7,2,
		11,2,3,
		11,3,4,
		10,5,3,
		10,3,2,
		10,2,6,
		10,6,9,
		10,9,5,
		8,1,7,
		1,9,6,
		7,6,2,
		7,1,6,
		5,4,3
	])
	
	if subdiv > 0:
		subdivide_sphere(surface_array, radius, subdiv)
	
	surface_array[Mesh.ARRAY_NORMAL] = gen_normals(surface_array)
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	mesh.surface_set_material(0, ResourceLoader.load("res://vertex_albedo_material.tres"))
	return mesh

func calc_average_tri_size(indices, verts) -> Array[float]:
	var sum = 0
	var min = 10000
	var max = -1
	for i in range(0, indices.size(), 3):
		var a = indices[i]
		var b = indices[i+1]
		var c = indices[i+2]
		var ab = verts[a] - verts[b]
		var ac = verts[a] - verts[c]
		var area = ab.cross(ac).length() / 2
		sum += area
		if area < min:
			min = area
		if area > max:
			max = area
	return [sum / (indices.size() / 3), min, max, max - min]
	
func get_big_tris(indices, verts, mean) -> Array[int]:
	var big_tris: Array[int] = []
	for i in range(0, indices.size(), 3):
		var a = indices[i]
		var b = indices[i+1]
		var c = indices[i+2]
		var ab = verts[a] - verts[b]
		var ac = verts[a] - verts[c]
		var area = ab.cross(ac).length() / 2
		if area > mean:
			big_tris.append_array([a, b, c])
	return big_tris

func gen_triangle(subdiv: int = 0) -> Mesh:
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	
	var verts = PackedVector3Array()
	var indices = PackedInt32Array()
	
	verts.append(Vector3(0,0,0))
	verts.append(Vector3(.5, cos(.5), 0))
	verts.append(Vector3(1,0,0))
	
	indices.append_array([0,1,2])
	
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_INDEX] = indices
	
	if (subdiv > 0):
		subdivide_triangles(surface_array, subdiv)
	
	surface_array[Mesh.ARRAY_NORMAL] = gen_normals(surface_array)
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	mesh.surface_set_material(0, ResourceLoader.load("res://vertex_albedo_material.tres"))
	return mesh
	
func vec3_to_color(v: PackedVector3Array) -> PackedColorArray:
	var c = PackedColorArray()
	c.resize(v.size())
	c.fill(Color.WEB_GREEN)
	for i in range(v.size()):
		c[i] = Color(abs(v[i].x), abs(v[i].y), abs(v[i].z), 1)
	return c
	
func gen_normals(surface_array: Array) -> PackedVector3Array:
	var verts: PackedVector3Array = surface_array[Mesh.ARRAY_VERTEX]
	var idx: PackedInt32Array = surface_array[Mesh.ARRAY_INDEX]
	var normals = PackedVector3Array()
	normals.resize(verts.size())
	normals.fill(Vector3.ZERO)
	
	for i in range(0, len(idx), 3):
		var v1: Vector3 = verts[idx[i]]
		var v2: Vector3 = verts[idx[i+1]]
		var v3: Vector3 = verts[idx[i+2]]
		
		var normal = (v3-v1).cross(v2-v1)
		normals[idx[i]] += normal
		normals[idx[i+1]] += normal
		normals[idx[i+2]] += normal
		
	for i in range(normals.size()):
		var normal: Vector3 = normals[i]
		normals[i] = normal.normalized()
		
	return normals

func subdivide_triangles(surface_array: Array, iterations: int = 1) -> Array:
	for _rounds in range(iterations):
		var vert_cache: Dictionary[Vector2i, int] = {}
		var new_idx = PackedInt32Array()
		for i in range(0, surface_array[Mesh.ARRAY_INDEX].size(), 3):
			var new_verts = _subdivide_triangle(surface_array[Mesh.ARRAY_VERTEX], surface_array[Mesh.ARRAY_INDEX], i, vert_cache)
			new_idx.append_array(new_verts)
		surface_array[Mesh.ARRAY_INDEX] = new_idx
	return surface_array
	
func subdivide_sphere(surface_array: Array, radius: float, iterations: int = 1) -> Array:
	for _rounds in range(iterations):
		var vert_cache: Dictionary[Vector2i, int] = {}
		var new_idx = PackedInt32Array()
		for i in range(0, surface_array[Mesh.ARRAY_INDEX].size(), 3):
			var verts = surface_array[Mesh.ARRAY_VERTEX]
			var new_verts = _subdivide_triangle(verts, surface_array[Mesh.ARRAY_INDEX], i, vert_cache)
			for j in range(new_verts.size()):
				verts[new_verts[j]] = verts[new_verts[j]].normalized() * radius
			new_idx.append_array(new_verts)
		surface_array[Mesh.ARRAY_INDEX] = new_idx
	return surface_array

func _subdivide_triangle(verts, indices, idx, cache) -> Array[int]:
	var v1 = indices[idx]
	var v2 = indices[idx + 1]
	var v3 = indices[idx + 2]
	var m1 = _add_middle_vert(verts, cache, v1, v2)
	var m2 = _add_middle_vert(verts, cache, v2, v3)
	var m3 = _add_middle_vert(verts, cache, v1, v3)
	return [
		v1, m1, m3,
		v2, m2, m1,
		v3, m3, m2,
		m1, m2, m3]

func _add_middle_vert(verts, cache, idx1, idx2) -> int:
	var new_idx
	if cache.has(Vector2i(idx1, idx2)):
		new_idx = cache[Vector2i(idx1, idx2)]
	else:
		new_idx = verts.size()
		verts.append(verts[idx1] + ((verts[idx2] - verts[idx1]) / 2))
		cache[Vector2i(idx1, idx2)] = new_idx
		cache[Vector2i(idx2, idx1)] = new_idx
	return new_idx
