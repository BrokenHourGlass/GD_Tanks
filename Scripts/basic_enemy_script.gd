extends KinematicBody

var path = []
var target_path_index = 0

#variables related to enemy life
export (int) var max_life = 10
var life = max_life

export (int) var speed = 300
var player_node

onready var nav = get_parent()
onready var mesh = $MeshInstance

func _ready():
	player_node = get_node("../../../player tank")
	life = max_life

func _physics_process(delta):
	
	if not player_node:
		return
	if path.empty():
		calculate_path()
	if not path.empty():
		move_along_path(delta)

func take_damage(damage):
	life -= damage
	if life > 0:
		update_albedo_green_value()
	else:
		queue_free()  # Remove the KinematicBody from the scene

func update_albedo_green_value():
	var material = mesh.get_surface_material(0)
	var current_albedo = material.albedo_color
	var new_green_value = float(life) / max_life * current_albedo.g
	material.albedo_color = Color(current_albedo.r, new_green_value, current_albedo.b)

func calculate_path():
	var navigation = get_parent()  # Adjust the path to the Navigation node in your main scene
	path = navigation.get_simple_path(global_transform.origin, player_node.global_transform.origin)
	target_path_index = 0

func move_along_path(delta):
	if target_path_index >= path.size():
		return

	var direction = (path[target_path_index] - global_transform.origin).normalized()
	var distance_to_target = (path[target_path_index] - global_transform.origin).length()

	var velocity = direction * speed
	var motion = velocity * delta

	if motion.length() >= distance_to_target:
		motion = direction * distance_to_target
		path.remove(0)

	move_and_slide(motion, Vector3.UP)

func connect_bullet_signal(bullet):
	bullet.connect("hit", self, "_on_bullet_hit")
