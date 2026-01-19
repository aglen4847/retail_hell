extends AnimatableBody3D

@onready var space := get_world_3d().direct_space_state
@onready var navigator := $Navigator
@onready var states := $EnemyStates
@onready var world := $"../World"

@export var viewing_angle := 90
@export var ray_divisions := 60
var player_in_sight_range: bool
var last_player_sight_value: bool
var velocity := 3
var wander_destination: Vector3
var destination_path: Array
var destination_path_iteration := 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	navigator.set_navigation_map($"../World".get_navigation_map())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	player_in_sight_range = $EnemyVision.can_see_player()
	
	# Add player detection to debug menu
	$"../Character/UserInterface/DebugPanel".add_property("Seen by Enemy", player_in_sight_range, 10)
	$"../Character/UserInterface/DebugPanel".add_property("Enemy Location", position, 11)
	$"../Character/UserInterface/DebugPanel".add_property("Enemy Moving To", wander_destination, 12)
	
	# Check if the player just became visible/invisible to the enemy this frame
	if player_in_sight_range and not last_player_sight_value:
		states.send_event("player_detected")
	elif not player_in_sight_range and last_player_sight_value:
		states.send_event("player_disappeared")
	
	#Set the current frame's value for the next frame to reference
	last_player_sight_value = player_in_sight_range


func _on_detection_region_area_entered(area: Area3D) -> void:
	if area == $"../Character/DetectionRegion":
		states.send_event("player_detected")


func _on_detection_region_area_exited(area: Area3D) -> void:
	if area == $"../Character/DetectionRegion" and not player_in_sight_range:
		states.send_event("player_disappeared")

func _on_following_state_processing(delta: float) -> void:
	look_at($"../Character".global_position)

# Actions while roaming store freely
func _on_free_wandering_state_physics_processing(delta: float) -> void:
	if $WanderCooldown.is_stopped():
		var rand = randi_range(0,100000)
		
		if rand == 1:
			states.send_event("follow_path")
			return # This state is complete
	
	if navigator.is_navigation_finished():
		states.send_event("start_standing")
		return
	
	var destination = navigator.get_next_path_position()
	print(destination)
	look_at(destination)
	global_position = global_position.move_toward(destination, velocity * delta)

# Actions while following predetermined path
func _on_following_path_state_physics_processing(delta: float) -> void:
	if debug.debug_enabled and Input.is_key_pressed(KEY_F1):
		states.send_event("roam")
	
	if $WanderCooldown.is_stopped():
		var rand = randi_range(0,1000)
		
		if rand == 1:
			states.send_event("roam")
			return # This state is complete
		
	if destination_path_iteration < destination_path.size():
		
		if abs((position - destination_path[destination_path_iteration]).length()) < 0.1:
			destination_path_iteration += 1
		else:
			look_at(global_position.move_toward(destination_path[destination_path_iteration], delta * velocity))
			global_position = global_position.move_toward(destination_path[destination_path_iteration], delta * velocity)
		
	else: 
		destination_path_iteration = 0
		states.send_event("start_standing")
		return
	
	if abs((position - destination_path.back()).length()) < 0.1:
		states.send_event("start_standing")

# When the enemy just starts walking along store path
func _on_following_path_state_entered() -> void:
	$WanderCooldown.start()
	print("switching to following path")
	var left_store_bound = Vector2(-10, 12) #TODO: replace these bounds when store layout is complete
	var right_store_bound = Vector2(10, -12)
	
	destination_path_iteration = 0
	
	wander_destination = Vector3(randf_range(left_store_bound.x, right_store_bound.x), 0, randf_range(left_store_bound.y, right_store_bound.y))
	
	var dest_point = world.astar.get_closest_position_in_segment(wander_destination)
	destination_path = world.astar.get_point_path(world.astar.get_closest_point(position), world.astar.get_closest_point(wander_destination))
	print(destination_path)

# When the enemy just starts roaming store freely
func _on_free_wandering_state_entered() -> void:
	$WanderCooldown.start()
	print("switching to free wander")
	var left_store_bound = Vector2(-10, 12) #TODO: replace these bounds when store layout is complete
	var right_store_bound = Vector2(10, -12)
	wander_destination = Vector3(randf_range(left_store_bound.x, right_store_bound.x), 0, randf_range(left_store_bound.y, right_store_bound.y))
	
	navigator.target_position = wander_destination
	print("wander destination: " + str(wander_destination))


func _on_standing_state_entered() -> void:
	$WanderCooldown.start()
	print("switching to standing")


func _on_standing_state_physics_processing(delta: float) -> void:
	if $WanderCooldown.is_stopped():
		var rand = randi_range(0,20)
		print(rand)
		
		if rand == 1:
			states.send_event("roam")
			return # This state is complete
		elif rand == 2:
			states.send_event("follow_path")
			return # This state is complete
