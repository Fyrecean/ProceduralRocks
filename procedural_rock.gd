extends Node3D

func _ready():
	var ico = $Rock.gen_icosahedron(1, 1)
	#var tri = $Rock.gen_triangle(4)
	$MeshDebugger.load_mesh(ico)
	$MeshDebugger.render_text()
