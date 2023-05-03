extends CanvasLayer

onready var reticle_sprite = $Sprite
onready var camera = get_viewport().get_camera()

func _process(delta):
	update_reticle_position()

func update_reticle_position():
	var mouse_pos_2d = get_viewport().get_mouse_position()
	var ray_from = camera.project_ray_origin(mouse_pos_2d)
	var ray_to = ray_from + camera.project_ray_normal(mouse_pos_2d) * 1000
	
	var space_state = get_tree().get_root().get_world().direct_space_state
	var result = space_state.intersect_ray(ray_from, ray_to, [], camera.cull_mask)
	
	if result:
		var target_pos = result.position
		reticle_sprite.global_position = camera.unproject_position(target_pos)
	else:
		reticle_sprite.global_position = Vector2(-1000, -1000)  # Hide the sprite off-screen when no object is beneath the mouse
