extends Node

func _ready():
	var ico = $IcoRock.gen_icosahedron(1, 2)
	$MeshDebugger.load_mesh(ico)
