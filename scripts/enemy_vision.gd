extends RayCast3D


func _process(_delta: float) -> void:
	global_position = $"..".global_position + Vector3(0, 1.5, 0)


func _physics_process(_delta: float) -> void:
	if $"../VisionRegion".overlaps_body($"../../Character"):
		enabled = true
		target_position = $"../../Character".global_position - global_position
	else:
		enabled = false


func can_see_player() -> bool:
	if get_collider() == $"../../Character" && $"../VisionRegion".overlaps_body($"../../Character"):
		return true
	return false
