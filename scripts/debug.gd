extends Node
var debug_enabled: bool = false
var debug_key = KEY_F3

signal enable_debug
signal disable_debug


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug"):
		toggle_debug()
		print("debug enabled: " + str(debug_enabled))


func toggle_debug():
	if debug_enabled:
		disable_debug.emit()
		debug_enabled = false
	else:
		enable_debug.emit()
		debug_enabled = true
