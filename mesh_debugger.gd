extends Node3D

var has_rendered_text = false
var meshes: Array[Mesh] = []
	
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("wireframe"):
		var vp = get_viewport()
		vp.debug_draw = vp.debug_draw ^ vp.DEBUG_DRAW_WIREFRAME
	if event.is_action_pressed("show_index"):
		if has_rendered_text:
			for child in get_children():
				if child is Label3D:
					child.visible = !child.visible
		else:
			render_text()
			has_rendered_text = true
			
func load_mesh(mesh: Mesh) -> void:
	meshes.append(mesh)

func render_text() -> void:
	for mesh in meshes:
		var surface_array = mesh.surface_get_arrays(0)
		var verts = surface_array[Mesh.ARRAY_VERTEX]
		var normals = surface_array[Mesh.ARRAY_NORMAL]
		for child in get_children():
			child.queue_free()
		for i in range(verts.size()):
			var label = Label3D.new()
			label.text = str(i)
			label.font_size = 8
			label.outline_size = 1
			label.position = verts[i] + (.05 * normals[i])
			label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			
			add_child(label)
