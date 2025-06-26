extends Label

func _on_noise_factor_value_changed(value: float) -> void:
	text = "Noise Scale: " + str(value)
