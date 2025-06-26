extends Node3D

var playing = false

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		$AnimationPlayer.play("Spin")
