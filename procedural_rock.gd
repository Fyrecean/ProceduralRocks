extends Node3D

func _ready():
	$Rock.generate()
	$MeshDebugger.load_mesh($Rock.mesh)
