extends CharacterBody2D
class_name PlayerScript
static var active_node: PlayerScript

const SPEED := 300.0
const RUN_ACCELERATION := 1200.0
const JUMP_VELOCITY := -400.0
var air_count := 5 # Coyote-time in frames

var can_double_jump = true
var wall_jump_count = 2 # Number of times you can wall jump before needing to land

var is_dashing := false 
var dash_distance := 100.0
var dash_end_position: Vector2
var dash_cooldown_seconds := 0.0 
var dash_direction := Vector2(0,0)

const DEFAULT_PLAYER_ZOOM := Vector2(2,2)
var target_position := global_position
var target_zoom := DEFAULT_PLAYER_ZOOM
var run_direction := 1.0

@onready var animated_sprite: AnimatedSprite2D = $animated_sprite
@onready var main_collider:= $main_collider
@onready var attack_cast := $attack_cast

func _ready():
	active_node = self
	CameraScript.active_node.player_node = active_node

func _physics_process(delta: float) -> void:
	# If not on the floor, add gravity. Else, reset ungrounded movement variables
	if not is_on_floor():
		velocity += get_gravity() * delta
		air_count -= 1
	else:
		air_count = 5
		can_double_jump = true
		wall_jump_count = 2

	_handle_jump()

	_handle_run(delta)	
	_handle_dash(delta)
	
	_handle_attack()
	
	move_and_slide()
	target_position = global_position


func flip(node: Node = self):
	for child in node.get_children():
		flip(child)
	if node != self: node.position.x *= -1


# Actual movement script for the dash
func _handle_dash(delta):
	
	if is_dashing:
		velocity = Vector2(0,0) 
		position = position.move_toward(dash_end_position, SPEED * 2 * delta)
		if position == dash_end_position:
			is_dashing = false
	else:
		dash_cooldown_seconds -= 1.0 * delta

	if dash_cooldown_seconds <= 0 and Input.is_action_just_pressed("dash"):
		dash_direction = Vector2(
			Input.get_axis("move_left", "move_right"),
			Input.get_axis("move_up", "move_down")
		)
		if not dash_direction.is_zero_approx():
			is_dashing = true
			dash_end_position = dash_direction.normalized() * dash_distance + position
			dash_cooldown_seconds = 1.0


func _handle_run(delta):
	var input_direction := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)

	var run_speed = SPEED
	if Input.is_action_pressed("run"): run_speed = SPEED * 1.5
	
	if sign(input_direction.x) == sign(velocity.x) * -1:
		velocity.x = move_toward(velocity.x, run_speed * input_direction.x, RUN_ACCELERATION * 2 * delta)
	elif input_direction.x == 0:
		velocity.x = move_toward(velocity.x, 0, RUN_ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, run_speed * input_direction.x, RUN_ACCELERATION * delta)

	_handle_animation(input_direction.x)


func _handle_animation(x_direction):
	if x_direction != 0 and x_direction != run_direction:
		animated_sprite.flip_h = not animated_sprite.flip_h
		flip()
		run_direction = sign(x_direction)

	# Play animations
	if is_on_floor():
		if x_direction == 0:
			animated_sprite.play("idle")
		elif Input.is_action_pressed("run"):
			animated_sprite.play("run")
		else:
			animated_sprite.play("walk")
	else:
		animated_sprite.play("jump")


func _handle_jump():
	if Input.is_action_just_pressed("jump") and air_count >= 0: # Grounded / cotoye-time jump
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_just_pressed("jump") and is_on_wall_only() and wall_jump_count > 0: # Wall jump
		velocity.y = JUMP_VELOCITY*(1 - 0.1 * wall_jump_count)
		wall_jump_count -= 1
	elif Input.is_action_just_pressed("jump") and can_double_jump: # Air jump
		velocity.y = JUMP_VELOCITY*0.9
		can_double_jump = false
	

func _handle_attack():
	if Input.is_action_just_pressed("attack"):
		for enemy in attack_cast.get_overlapping_bodies():
			enemy.take_damage(10)

