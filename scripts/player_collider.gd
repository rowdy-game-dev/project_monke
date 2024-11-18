extends CollisionShape2D

enum Stance {
	IDLE,
	RUNNING,
}

var stance_transforms = {
	Stance.RUNNING: {
		"shape_size": Vector2(145,105),
		"relative_position": Vector2(22,12),
	},
	Stance.IDLE: {
		"shape_size": Vector2(100,155),
		"relative_position": Vector2(-0.25,-12.25),
	},
}

var current_stance := Stance.IDLE
var is_flipped := false

func on_stance_change(stance: Stance):
	current_stance = stance
	var stance_transform = stance_transforms[stance]
	shape.size = stance_transform["shape_size"]
	position = stance_transform["relative_position"]
	if is_flipped: position.x *= -1

func set_direction(run_direction):
	if run_direction == 0: return
	if run_direction < 0:
		is_flipped = true
	else:
		is_flipped = false
	

func _process(delta: float) -> void:
	if $"../animated_sprite".animation == "idle":
		on_stance_change(Stance.IDLE)
	else:
		on_stance_change(Stance.RUNNING)
	
	set_direction(get_parent().run_direction)

func _ready() -> void:
	on_stance_change(current_stance)