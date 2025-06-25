extends Node3D

var has_rendered_text = false
var meshes: Array[Mesh] = []

func load_mesh(mesh: Mesh) -> void:
	meshes.append(mesh)

func render_text() -> void:
	has_rendered_text = true
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
			if normals:
				label.position = verts[i] + (.05 * normals[i])
			else:
				label.position = verts[i]
			label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			
			add_child(label)


func _on_check_button_toggled(toggled_on: bool) -> void:
	if has_rendered_text:
		for child in get_children():
			if child is Label3D:
				child.visible = toggled_on
	else:
		render_text()


var _debug_options = {
	0: Viewport.DEBUG_DRAW_DISABLED,
	1: Viewport.DEBUG_DRAW_WIREFRAME,
	2: Viewport.DEBUG_DRAW_NORMAL_BUFFER,
}

func _on_item_list_item_selected(index: int) -> void:
	RenderingServer.set_debug_generate_wireframes(true)
	var vp = get_viewport()
	vp.debug_draw = _debug_options[index]
