extends VBoxContainer

signal changed(vector: Vector3)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$X/XSlider.value_changed.connect(_on_slider_changed)
	$Y/YSlider.value_changed.connect(_on_slider_changed)
	$Z/ZSlider.value_changed.connect(_on_slider_changed)

func _on_slider_changed(_val):
	changed.emit(Vector3($X/XSlider.value, $Y/YSlider.value, $Z/ZSlider.value))
