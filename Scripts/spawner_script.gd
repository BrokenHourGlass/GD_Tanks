extends Node

onready var rng = get_parent().get_rng()

export (PackedScene) var enemy_scene
export (int) var max_population = 10
export (Array) var spawn_boundaries
export (float) var spawn_interval = 1.0

var current_population = 0
var timer

func _ready():
	timer = Timer.new()
	timer.set_wait_time(spawn_interval)
	timer.connect("timeout", self, "_on_Timer_timeout")
	add_child(timer)
	timer.start()

func _on_Timer_timeout():
	if current_population < max_population:
		while current_population < max_population:
			var spawn_location = choose_spawn_location()
			if spawn_location:
				spawn_enemy(spawn_location)

func choose_spawn_location():
	if spawn_boundaries.empty():
		return null

	var camera = get_viewport().get_camera()
	var spawn_location = null
	var navigation_node = get_node("../../platform/Navigation")

	for _i in range(10):  # Try 10 times to find a spawn location
		var min_boundary = spawn_boundaries[0]
		var max_boundary = spawn_boundaries[1]
		
		var random_position = Vector3(
			rand_range(min_boundary.x, max_boundary.x),
			rand_range(min_boundary.y, max_boundary.y),
			rand_range(min_boundary.z, max_boundary.z)
		)

		# Get the closest point on the navigation mesh
		var nav_mesh_point = navigation_node.get_closest_point(random_position)

		var spawn_visible = camera.is_position_behind(nav_mesh_point)
		if not spawn_visible:
			spawn_location = nav_mesh_point
			break

	return spawn_location

func spawn_enemy(spawn_location):
	var enemy = enemy_scene.instance()

	# Make the material unique for each enemy instance
	var mesh_instance = enemy.get_node("MeshInstance") # Replace with the correct name of the MeshInstance node in your enemy scene
	var material = mesh_instance.get_surface_material(0)
	mesh_instance.set_surface_material(0, material.duplicate())

	# Get the reference to the Navigation node in your main scene
	var navigation_node = get_node("../../platform/Navigation") # Replace with the correct path

	# Add the enemy as a child of the Navigation node
	navigation_node.add_child(enemy)
	
	enemy.global_transform.origin = spawn_location
	
	current_population += 1
	enemy.connect("tree_exiting", self, "_on_Enemy_tree_exiting")


func _on_Enemy_tree_exiting():
	current_population -= 1
	var randint = rng.randi_range(0, 100)
	if rng.randi_range(0, 100) < 10:
		max_population += 1
