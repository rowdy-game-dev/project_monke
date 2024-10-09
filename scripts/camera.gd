extends Camera2D

enum Anchors {PLAYER, STATIC}
const smooth_move_factor := 10.0
const smooth_zoom_factor := 10.0 
var current_anchor := Anchors.PLAYER
var current_camera_zone = null
var anchor_offset := Vector2(10,0)
@onready var player_node = get_node("/root/Node2D/player")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(player_node)
	global_position = player_node.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
