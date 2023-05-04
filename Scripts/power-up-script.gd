extends Spatial

export (Array, PackedScene) var bullet_scenes
export (Array, Color) var colors

var assigned_bullet_scene = null

onready var mesh_instance = $MeshInstance
onready var area = $Area

func _ready():
	assign_bullet_and_color()

	area.connect("body_entered", self, "_on_area_body_entered")

func assign_bullet_and_color():
	var index = randi() % bullet_scenes.size()

	assigned_bullet_scene = bullet_scenes[index]
	mesh_instance.set_surface_material(0, make_colored_material(colors[index]))

func make_colored_material(color):
	var material = SpatialMaterial.new()
	material.albedo_color = color
	return material

func _on_area_body_entered(body):
	if body.is_in_group("player"):
		body.change_bullet_type(assigned_bullet_scene)
		queue_free()
