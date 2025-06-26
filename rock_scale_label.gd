extends Label


func _on_rock_scale_sliders_changed(vector: Vector3) -> void:
	text = "Rock Scale: " + str(vector)
