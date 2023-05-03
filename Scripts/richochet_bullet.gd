extends "res://Scripts/bullet_script.gd"

var bounce_counts: int = 2

func _ready():
	can_collide = false

func _physics_process(delta):
	if not bounce_counts > 0:
		can_collide = true
	
	# Move the ball using the current velocity
	#move_and_slide_with_snap(velocity, Vector3.UP)
	
	# Check if there was a collision during the last move
	if get_slide_count() > 0 and bounce_counts > 0:
		# Calculate the bounce vector based on the collision normal
		var bounce_vector = velocity.bounce(get_slide_collision(0).normal)
		
		# Update the velocity with the bounce vector
		velocity = bounce_vector
		
		# Decrement the bounce_counts
		bounce_counts -= 1
