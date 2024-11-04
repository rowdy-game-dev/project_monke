extends CharacterBody2D
class_name PlayerScript


const SPEED = 100.0
const JUMP_VELOCITY = -250.0
var air_count = 5 # Coyote-time in frames

var can_double_jump = true
var wall_jump_count = 2 # Number of times you can wall jump before needing to land

var dashing := false # Is the character supposed to be dashing?
var dash_counter := 0 # Dash duration
var dash_cooldown := 60 # Time between the end of a dash and the next one
var dash_direction := Vector2(0,0)

const DEFAULT_PLAYER_ZOOM := Vector2(2,2)
var target_position := global_position
var target_zoom := DEFAULT_PLAYER_ZOOM

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var main_collider: CollisionShape2D = $CollisionShape2D
@onready var wall_collision_l: CollisionShape2D = $WallCollisionL
@onready var wall_collision_r: CollisionShape2D = $WallCollisionR

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	
	# If not on the floor, add gravity. Else, reset ungrounded movement variables
	if not is_on_floor():
		velocity += get_gravity() * delta * 0.75
		air_count -= 1
	else:
		air_count = 5
		can_double_jump = true
		wall_jump_count = 2

	# Handle jump.
	jump()

	# Flips the Sprite horizontally based on direction (-1, 0, 1)
	animation()

	if direction:
		velocity.x = direction * SPEED
		if Input.is_action_pressed("run"):
			velocity.x *= (3.0/2.0)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if is_on_floor() and dash_cooldown >= 2:
		dash_cooldown -= 2
	
	dash()
	
	move_and_slide()
	target_position = global_position

# Actual movement script for the dash
func dash():
	dash_counter -= 1
	
	if (dash_counter > 0):
		velocity.x = dash_direction.x * SPEED * 2
		velocity.y = dash_direction.y * SPEED * 2
	else:
		dashing = false
		dash_cooldown -= 1

	if dash_cooldown <= 0 and Input.is_action_just_pressed("dash"):
		dash_direction = Vector2(
			Input.get_axis("move_left", "move_right"),
			Input.get_axis("move_up", "move_down")
		)
		if not dash_direction.is_zero_approx():
			dashing = true
			dash_counter = 10
			dash_cooldown = 60

func animation():
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction > 0:
		animated_sprite.flip_h = false
		flip_hitbox(false)
	elif direction < 0:
		animated_sprite.flip_h = true
		flip_hitbox(true)
	
	# Play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		elif Input.is_action_pressed("run"):
			animated_sprite.play("run")
		else:
			animated_sprite.play("walk")
	else:
		animated_sprite.play("jump")

func flip_hitbox(flip_true):
	main_collider.position.x = 20 * int(not flip_true)
	wall_collision_l.position.x = main_collider.position.x - 95
	wall_collision_r.position.x = main_collider.position.x + 95

func jump():
	if Input.is_action_just_pressed("jump") and air_count >= 0: # Grounded / cotoye-time jump
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_just_pressed("jump") and is_on_wall_only() and wall_jump_count > 0: # Wall jump
		velocity.y = JUMP_VELOCITY*(1 - 0.1 * wall_jump_count)
		wall_jump_count -= 1
	elif Input.is_action_just_pressed("jump") and can_double_jump: # Air jump
		velocity.y = JUMP_VELOCITY*0.9
		can_double_jump = false
	
