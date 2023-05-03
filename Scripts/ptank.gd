extends KinematicBody

signal hit(hp)

export (PackedScene) var bullet_scene

onready var turret = $tank/turret
onready var spawn_point = $tank/turret/bullet_spawn
onready var fire_cool_down = $fire_cool_down

#character values
export (int) var hp = 5

var vulnerable = true
var bullet_cool_down = false

#physics values
var velocity = 750.0
var rotation_speed = 3.0
var bullet_speed = 45.0

func _ready():
	pass

func get_health():
	return hp

func _physics_process(delta):
	var forward_movement = 0.0

	if Input.is_action_pressed("move_backward"):
		forward_movement += velocity
	if Input.is_action_pressed("move_forward"):
		forward_movement -= velocity

	var move_direction = transform.basis.z * forward_movement
	var motion = move_direction * delta
	motion = move_and_slide(motion, Vector3.UP)

	if Input.is_action_pressed("move_left"):
		rotation_degrees.y += rotation_speed
	if Input.is_action_pressed("move_right"):
		rotation_degrees.y -= rotation_speed
		
	if Input.is_action_pressed("left_click"):
		fire_bullet()
	
	rotate_turret_to_mouse()
	has_tank_hit_enemy()

func rotate_turret_to_mouse():
	var viewport = get_viewport()
	var camera = viewport.get_camera()

	# Get the mouse position in 2D viewport space
	var mouse_pos_2d = viewport.get_mouse_position()

	# Convert the 2D mouse position to a 3D world ray
	var ray_from = camera.project_ray_origin(mouse_pos_2d)
	var ray_to = ray_from + camera.project_ray_normal(mouse_pos_2d) * 1000

	# Perform a raycast to find the point where the ray intersects with the world
	var space_state = get_world().direct_space_state
	
	# Get all nodes in the "ignore_turret_ray" group
	var ignore_nodes = get_tree().get_nodes_in_group("ignore_turret_ray")

	# Perform the raycast excluding nodes in the "ignore_turret_ray" group
	var result = space_state.intersect_ray(ray_from, ray_to, ignore_nodes, camera.cull_mask)

	if result:
		# Get the position where the ray intersects with the world
		var target_pos = result.position

		# Calculate the direction from the turret to the target position
		var turret_to_target = -(target_pos - turret.global_transform.origin).normalized()
		turret_to_target.y = 0  # Ignore the Y axis

		# Calculate the angle between the turret's forward direction and the target direction
		var turret_forward = turret.global_transform.basis.z
		var angle = turret_forward.angle_to(turret_to_target)

		# Rotate the turret towards the target direction
		turret.rotate_y(angle * sign(turret_forward.cross(turret_to_target).y))

func fire_bullet():
	if not bullet_scene:
		print("No bullet scene assigned")
		return
	
	if not bullet_cool_down:
		bullet_cool_down = !bullet_cool_down
		var bullet = bullet_scene.instance()
		fire_cool_down.start(bullet.get_timer_cost())
		bullet.global_transform = spawn_point.global_transform
		#bullet_speed = bullet.get_speed()
	
		# Set the initial velocity of the bullet in its script
		bullet.set_velocity(-spawn_point.global_transform.basis.z)
	
		get_tree().get_root().add_child(bullet)
	

func take_damage():
	hp -= 1
	vulnerable = false
	$invincibilityTimer.start()

func has_tank_hit_enemy():
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("enemies") and vulnerable:
			take_damage()
			emit_signal("hit", hp)
			print(hp)

func _on_Timer_timeout():
	vulnerable = true


func _on_fire_cool_down_timeout():
	bullet_cool_down = !bullet_cool_down
