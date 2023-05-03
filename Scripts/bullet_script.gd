extends KinematicBody

signal hit(damage)

var velocity = Vector3.ZERO

export (int) var damage = 5
export (float) var timer_cost = 0.5
export (bool) var can_collide
export (float) var speed = 1

func _ready():
	can_collide = true
	set_speed(speed)

func _physics_process(delta):
	velocity = move_and_slide_with_snap(velocity, Vector3.UP, Vector3.ZERO, true)
	check_collision()

func set_speed(new_speed):
	speed = new_speed

func set_velocity(new_velocity):
	velocity = new_velocity.normalized() * speed

func set_collision(setter: bool):
	can_collide = setter

func set_timer_cost(cost: float):
	timer_cost = cost

func set_damage(dmg: int):
	damage = dmg

func check_collision():
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("enemies"):
			collider.take_damage(damage)
			emit_signal("hit", damage)
		if can_collide:
			queue_free()
		break

func get_damage():
	return damage

func get_collision():
	return can_collide

func get_timer_cost():
	return timer_cost
	
func get_speed():
	return speed

func get_velocity():
	return velocity

