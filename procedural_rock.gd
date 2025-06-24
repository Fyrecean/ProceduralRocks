extends Node3D

func _ready():
	$Rock.generate()
	$MeshDebugger.render($Rock.mesh)
