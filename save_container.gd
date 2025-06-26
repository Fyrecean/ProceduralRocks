extends HFlowContainer
signal save(path: String)

func _on_save_button_pressed() -> void:
	save.emit($PathEntry.text)
