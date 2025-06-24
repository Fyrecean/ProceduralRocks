extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func generate() -> void:
	var surface_array = gen_triangle()
	surface_array = subdivide_triangles(surface_array)
	surface_array[Mesh.ARRAY_NORMAL] = gen_normals(surface_array)
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	mesh.surface_set_material(0, ResourceLoader.load("res://vertex_albedo_material.tres"))
	ResourceSaver.save(mesh, "res://icosphere.tres", ResourceSaver.FLAG_COMPRESS)

func gen_triangle() -> Array:
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
	return surface_array
	
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
	
func subdivide_triangles(surface_array: Array) -> Array:
	var verts: PackedVector3Array = surface_array[Mesh.ARRAY_VERTEX]
	var old_idx = surface_array[Mesh.ARRAY_INDEX]
	
	var v1 = old_idx[0]
	var v2 = old_idx[1]
	var v3 = old_idx[2]
	
	var m1 = len(verts)
	verts.append(get_mid_point(verts[v1], verts[v2]))
	var m2 = m1 + 1
	verts.append(get_mid_point(verts[v2], verts[v3]))
	var m3 = m1 + 2
	verts.append(get_mid_point(verts[v1], verts[v3]))
	
	var new_idx = PackedInt32Array()
	new_idx.append_array([v1, m1, m3])
	new_idx.append_array([v2, m2, m1])
	new_idx.append_array([v3, m3, m2])
	new_idx.append_array([m1, m2, m3])
	
	surface_array[Mesh.ARRAY_INDEX] = new_idx
	return surface_array
	
func get_mid_point(p1: Vector3, p2: Vector3) -> Vector3:
	return p1 + ((p2 - p1) / 2)
	
