extends Node

var icosphere: Array
var rock: Array

var rock_scale: Vector3 = Vector3.ONE
var noise_scale: float = .55
var subdivs: int = 1

func _ready():
	icosphere = $IcoRock.gen_icosahedron(.9, subdivs)
	rock = $IcoRock.stretch_rock(icosphere, rock_scale, noise_scale)
	$IcoRock.mesh = $IcoRock.array_to_mesh(rock)
	$MeshDebugger.load_mesh($IcoRock.mesh)

func _on_save_container_save(path: String) -> void:
	ResourceSaver.save($IcoRock.array_to_mesh(rock), path)


func _on_vector_sliders_changed(vector: Vector3) -> void:
	rock_scale = vector
	regenerate_rock()


func _on_noise_scale_value_changed(value: float) -> void:
	noise_scale = value
	regenerate_rock()

func regenerate_rock():
	rock = $IcoRock.stretch_rock(icosphere, rock_scale, noise_scale)
	$IcoRock.mesh = $IcoRock.array_to_mesh(rock)
	$MeshDebugger.clear_meshes()
	$MeshDebugger.load_mesh($IcoRock.mesh)


func _on_subdivisions_value_changed(value: float) -> void:
	subdivs = int(value)
	icosphere = $IcoRock.gen_icosahedron(.9, subdivs)
	regenerate_rock()
