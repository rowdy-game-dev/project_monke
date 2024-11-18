extends Area2D

@onready var player_node = get_tree().root.get_child(0).get_node("player")
@onready var camera_node = get_tree().root.get_child(0).get_node("camera")

@export var global_position_is_target := true
@export var target_position: Vector2 = Vector2()
@export var target_zoom: Vector2 = PlayerScript.DEFAULT_PLAYER_ZOOM


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if global_position_is_target: 
		target_position = global_position

	body_entered.connect(on_area_entered)
	body_exited.connect(on_area_exited)

func on_area_entered(body):
	if body == player_node:
		camera_node.on_camera_area_entered(self)

func on_area_exited(body):
	if body == player_node and player_node not in get_overlapping_areas():
		camera_node.on_camera_area_exited(self)