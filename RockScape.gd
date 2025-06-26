extends Node3D

@export var range_x: float = 30
@export var range_z: float = 12

func _ready():
	var rng = RandomNumberGenerator.new()
	for i in range(range_x):
		for j in range(range_z):
			var mesh = $RockGenerator.get_rock(3,Vector3(randf_range(1,1.5),randf_range(.5,1),randf_range(1,1.5)), .9)
			var mesh_instance = MeshInstance3D.new()
			mesh_instance.mesh = mesh
			mesh_instance.translate(Vector3(i * 3, 0, j * 3))
			mesh_instance.rotate_y(randf_range(0, 2*PI))
			add_child(mesh_instance)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		$Camera3D/AnimationPlayer.play("Camera Track")
