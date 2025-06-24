extends Node3D

func _init():
	RenderingServer.set_debug_generate_wireframes(true)
	
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("wireframe"):
		var vp = get_viewport()
		vp.debug_draw = vp.debug_draw ^ vp.DEBUG_DRAW_WIREFRAME
	if event.is_action_pressed("show_index"):
		for child in get_children():
			if child is Label3D:
				child.visible = !child.visible

func render(mesh: Mesh) -> void:
	var surface_array = mesh.surface_get_arrays(0)
	var verts = surface_array[Mesh.ARRAY_VERTEX]
	var normals = surface_array[Mesh.ARRAY_NORMAL]
	var index = surface_array[Mesh.ARRAY_INDEX]
	for child in get_children():
		child.queue_free()
	for i in range(verts.size()):
		var label = Label3D.new()
		label.text = str(i)
		label.position = verts[i] + (.05 * normals[i])
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		
		add_child(label)
