extends NavigationRegion3D

var store_path_points = [
	Vector3(10, 0, 12),
	Vector3(5, 0, 12),
	Vector3(0, 0, 12),
	Vector3(-5, 0, 12),
	Vector3(-10, 0, 12),
	Vector3(10, 0, -12),
	Vector3(5, 0, -12),
	Vector3(0, 0, -12),
	Vector3(-5, 0, -12),
	Vector3(-10, 0, -12),
]

var astar = AStar3D.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(store_path_points.size()):
		astar.add_point(i, store_path_points.get(i))
	
	astar.connect_points(0, 5)
	astar.connect_points(1, 6)
	astar.connect_points(2, 7)
	astar.connect_points(3, 8)
	astar.connect_points(4, 9)
	
	astar.connect_points(0, 1)
	astar.connect_points(1, 2)
	astar.connect_points(2, 3)
	astar.connect_points(3, 4)
	
	astar.connect_points(5, 6)
	astar.connect_points(6, 7)
	astar.connect_points(7, 8)
	astar.connect_points(8, 9)


func _process(_delta: float) -> void:
	if debug.debug_enabled:
		var points = astar.get_point_ids()
		
		while !points.is_empty():
			for point in points:
				if astar.are_points_connected(points[0], point):
					DebugDraw3D.draw_line(astar.get_point_position(points[0]), astar.get_point_position(point))
			points.remove_at(0)
