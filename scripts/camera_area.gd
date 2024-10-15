extends Area2D

@onready var player_node = $"/root/test_level/Player"
@onready var camera_node = $"/root/test_level/camera"

@export var target_position: Vector2 = self.global_position
@export var target_zoom: Vector2 = Vector2(1,1)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(on_area_entered)
	body_exited.connect(on_area_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_area_entered(body):
	if body == player_node:
		camera_node.on_camera_area_entered(self)

func on_area_exited(body):
	if body == player_node:
		camera_node.on_camera_area_exited(self)