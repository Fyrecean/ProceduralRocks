extends Node

func _ready():
	var ico = $IcoRock.gen_icosahedron(1, 2)
	ResourceSaver.save(ico, "procedural_objects/icosphere.tres")
	$MeshDebugger.load_mesh(ico)
