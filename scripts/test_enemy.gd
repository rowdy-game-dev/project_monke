extends CharacterBody2D


@onready var main_hitbox := $main_hitbox
@onready var agro_area := $agro_area

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	_move_toward_player(delta)
	_handle_jump(delta)
	
	_gravity(delta)
	move_and_slide()

func _handle_jump(delta):
	if is_on_wall():
		body_jump(delta)

func body_jump(delta):
	if get_node_or_null("jumping_countdown"): return
	
	velocity.y = -400
	var jumping_countdown = Timer.new()
	jumping_countdown.name = "jumping_countdown"
	jumping_countdown.wait_time = 3.0
	add_child(jumping_countdown)
	jumping_countdown.timeout.connect(func():
		jumping_countdown.queue_free()
	)
	jumping_countdown.start()

func take_damage(int):
	var force_direction = get_tree().root.get_child(0)\
		.get_node("player")\
		.global_position.direction_to(global_position)

func _move_toward_player(delta):
	for body in agro_area.get_overlapping_bodies():
		if body.name == "player":
			velocity.x = (50 * sign(body.global_position.x - global_position.x))

func _gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta