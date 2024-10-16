extends Camera2D
class_name CameraScript

const SMOOTH_MOVE_FACTOR := 3.0
const DEFAULT_RUN_OFFSET := Vector2(50,0)

@onready var player_node: PlayerScript = $"/root/test_level/Player"
var target_node: Node2D	 = null
var target_offset := Vector2(0,0)
var in_camera_area := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target_node = player_node
	global_position = target_node.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = move_toward_node(target_node, delta)	

func move_toward_node(target_node: Node2D, delta):
	var target_position = target_node.global_position + target_offset
	return global_position.lerp(target_position, SMOOTH_MOVE_FACTOR * delta)
	
func set_player_node(node):
	player_node = node
