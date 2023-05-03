extends Node

onready var health_bar = $Control/HBoxContainer
onready var player = get_node("../player tank")

var max_health: int
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	max_health = player.get_health()
	initialize_health_bar(player.get_health())

func get_rng():
	return rng

func initialize_health_bar(max_health: int) -> void:
	#ensures health bar is empty before health bar is setup
	while health_bar.get_child_count() > 0:
		health_bar.get_child(0).queue_free()
	
	#creates children for to measure as health
	for _i in range(max_health):
		var health_sprite = TextureRect.new()
		health_sprite.texture = preload("res://assets/sprites/altered_gear.png")
		health_bar.add_child(health_sprite)

func update_health_bar(health_value: int) -> void:
	var current_health = $Control/HBoxContainer.get_child_count()
	
	# Hide health sprites based on the current health value
	for i in range(current_health):
		$Control/HBoxContainer.get_child(i).visible = i < health_value


func _on_player_tank_hit(hp):
	update_health_bar(hp)
