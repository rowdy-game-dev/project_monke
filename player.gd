extends CharacterBody2D

# Constants for movement and gravity
const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 900.0

# Player state variables
var health = 100
var player_alive = true

# Attack state variables
var enemy_in_attack_range = false
var enemy_attack_cooldown = true

# Physics process handles movement and gravity
func _physics_process(delta: float) -> void:
	if not player_alive:
		return # If player is dead, don't process movement

	# Apply gravity if not on the floor
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0  # Reset y-velocity when on the floor

	# Handle player movement
	handle_movement(delta)
	
	# Handle enemy attack logic if in range
	enemy_attack()

	# Handle player death if health is 0 or less
	if health <= 0:
		handle_death()


# Function to handle movement, including walking and jumping
func handle_movement(delta: float) -> void:
	# Handle jumping when the player presses the jump button and is on the floor
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle movement along the x-axis
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Apply movement
	move_and_slide()


# Function to handle enemy attack when in range
func enemy_attack() -> void:
	if enemy_in_attack_range and enemy_attack_cooldown:
		health -= 10
		enemy_attack_cooldown = false
		$attack_cooldown.start()  # Start attack cooldown timer
		print("Health:", health)


# Function to handle player death
func handle_death() -> void:
	player_alive = false  # Set player as dead
	health = 0  # Prevent health from going negative
	print("Player has been killed")
	get_tree().reload_current_scene()
	#self.queue_free()  # causing a glitch NOTE learn how to make player respawn


# Signal handler for entering enemy's hitbox
func _on_players_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_in_attack_range = true


# Signal handler for exiting enemy's hitbox
func _on_players_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_in_attack_range = false


# Signal handler for resetting attack cooldown
func _on_attack_cooldown_timeout() -> void:
	enemy_attack_cooldown = true
