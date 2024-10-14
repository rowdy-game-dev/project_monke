extends Camera2D
class_name CameraScript

var player_node: PlayerScript = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not player_node: return

	global_position = player_node.global_position

func set_player_node(node):
	player_node = node
