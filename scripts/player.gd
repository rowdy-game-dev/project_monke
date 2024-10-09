extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -250.0
var airCount = 5 # Coyote-time in frames

var canDoubleJump = true
var wallJumpCount = 2 # Number of times you can wall jump before needing to land

var dashing = false # Is the character supposed to be dashing?
var dashCounter = 60 # Dash duration
var dashCooldown = 60 # Time between the end of a dash and the next one
var dashX = 0 # Horizontal dash direction
var dashY = 0 # Vertical dash direction

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var main_collider: CollisionShape2D = $CollisionShape2D
@onready var wall_collision_l: CollisionShape2D = $WallCollisionL
@onready var wall_collision_r: CollisionShape2D = $WallCollisionR

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	
	# If not on the floor, add gravity. Else, reset ungrounded movement variables
	if not is_on_floor():
		velocity += get_gravity() * delta * 0.75
		airCount -= 1
	else:
		airCount = 5
		canDoubleJump = true
		wallJumpCount = 2

	# Handle jump.
	jump()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	# Flips the Sprite horizontally based on direction (-1, 0, 1)
	animation()
	
	if not dashing:
		if tryDash():
			dashing = true
			dashCooldown = 60
		else:
			dashCounter = 10
			
			if dashCooldown > 0:
				dashCooldown -= 1
				
			if direction and not Input.is_action_pressed("run"):
				velocity.x = direction * SPEED * 0.66
			elif direction and Input.is_action_pressed("run"):
				velocity.x = direction * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		dash()
	
	# Makes the dash come back three times faster on the ground
	if is_on_floor() and dashCooldown >= 2:
		dashCooldown -= 2
	
	move_and_slide()

# If you press the dash button, this returns if you can dash and records the intended direction of the dash
func tryDash():
	var direction := Input.get_axis("move_left", "move_right")
	
	if dashCooldown <= 0 and (Input.is_action_just_pressed("dash") or Input.is_action_pressed("dash")):
		if (Input.is_action_pressed("move_left")):
			dashX = -1
		elif (Input.is_action_pressed("move_right")):
			dashX = 1
		else:
			dashX = 0
		
		if (Input.is_action_pressed("move_up")):
			dashY = -1
		elif (Input.is_action_pressed("move_down") && (Input.is_action_pressed("move_left") || Input.is_action_pressed("move_right"))):
			dashY = 1
		elif (Input.is_action_pressed("move_down")):
			dashY = 1.5
		else:
			dashY = 0
		
		if (dashX != 0 or dashY != 0):
			return true
	return false

# Actual movement script for the dash
func dash():
	dashCounter -= 1
	
	if (dashCounter > 0):
		velocity.x = dashX * SPEED * 2
		velocity.y = dashY * SPEED * 2
	else:
		velocity.y /= 2
	
	if dashCounter <= 0:
		dashing = false

func animation():
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
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

func jump():
	if Input.is_action_just_pressed("jump") and airCount >= 0: # Grounded / cotoye-time jump
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_just_pressed("jump") and is_on_wall_only() and wallJumpCount > 0: # Wall jump
		velocity.y = JUMP_VELOCITY*(1 - 0.1 * wallJumpCount)
		wallJumpCount -= 1
	elif Input.is_action_just_pressed("jump") and canDoubleJump: # Air jump
		velocity.y = JUMP_VELOCITY*0.9
		canDoubleJump = false
	
