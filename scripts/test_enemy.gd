extends RigidBody2D

@onready var main_hitbox := $main_hitbox

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func take_damage(node):
	var force_direction = get_tree().root.get_child(0)\
		.get_node("player")\
		.global_position.direction_to(global_position)

	apply_force(force_direction * 10000)