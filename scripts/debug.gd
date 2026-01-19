extends Node
var debug_enabled: bool = false
var debug_key = KEY_F3

signal enable_debug
signal disable_debug

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == debug_key:
			toggle_debug()
			print("debug enabled: " + str(debug_enabled))


func toggle_debug():
	if debug_enabled:
		disable_debug.emit()
		debug_enabled = false
	else:
		enable_debug.emit()
		debug_enabled = true
