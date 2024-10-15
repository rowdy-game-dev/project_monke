extends Camera2D
class_name CameraScript

const PLAYER_SMOOTH_MOVE_FACTOR := 4.0
const AREA_SMOOTH_MOVE_FACTOR := 3.0
const DEFAULT_RUN_OFFSET := Vector2(50,0)
var current_smooth_move_factor := PLAYER_SMOOTH_MOVE_FACTOR

const DEFAULT_PLAYER_ZOOM := Vector2(2,2)
const SMOOTH_ZOOM_FACTOR := 1.0
const ZOOM_ALLOWANCE := 0.01

@onready var player_node: PlayerScript = $"/root/test_level/Player"
var previous_zoom := DEFAULT_PLAYER_ZOOM
var target_node: Node2D	 = null
var target_offset := Vector2(0,0)
var target_zoom := Vector2(2,2)
var in_camera_area := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target_node = player_node
	global_position = target_node.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = move_toward_target(delta)	
	zoom = zoom_toward_target(delta)

func move_toward_target(delta):
	var target_position = target_node.global_position + target_offset
	return global_position.lerp(target_position, current_smooth_move_factor * delta)

func on_camera_area_entered(camera_area):
	new_target(camera_area)
	target_zoom = Vector2(3,3)
	current_smooth_move_factor = AREA_SMOOTH_MOVE_FACTOR

func on_camera_area_exited(camera_area):
	if camera_area == target_node:
		new_target(player_node)
		target_zoom = DEFAULT_PLAYER_ZOOM
		current_smooth_move_factor = PLAYER_SMOOTH_MOVE_FACTOR

func new_target(new_node):
	in_camera_area = (new_node != player_node)
	previous_zoom = zoom
	target_node = new_node


func zoom_toward_target(delta):
	if zoom == target_zoom: return target_zoom

	if abs(target_zoom.x - zoom.x) <= ZOOM_ALLOWANCE:
		target_zoom = zoom
		return zoom

	
	return zoom.lerp(target_zoom, SMOOTH_ZOOM_FACTOR * delta)