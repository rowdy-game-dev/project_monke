extends CharacterBody2D

var speed = 50
const GRAVITY = 900.0
var player_chase = false
var player = null
var health = 100
var player_in_attack_zone = false
var can_take_damage = true

# Timer for handling random animations
var random_animation_interval = 3.0  # Time between switching to a random animation
var random_animation_time = 0.0  # Track the elapsed time for random animations
var is_playing_random_animation = false  # Flag to check if a random animation is currently playing

# Possible animations (Idle is not included for random selection)
var animations = ["Walk_To_Left", "Walk_To_Right", "Jump"]

func _ready():
	randomize()  # Ensure randomness for randi()
	$AnimatedSprite2D.play("Idle")  # Start with Idle animation


func _physics_process(delta):
	
	deal_with_damage()
	
	if player_chase:
		position.x =  move_toward(position.x, player.position.x, speed * delta)
		move_and_collide(Vector2(0,0))
		
		if(player.position.x - position.x) < 0:
			$AnimatedSprite2D.play("Walk_To_Left")
		else:
			$AnimatedSprite2D.play("Walk_To_Right")
	else:
		# Handle switching between Idle and random animations
		handle_idle_and_random_animations(delta)
		
	# Apply gravity if not on the floor
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0  # Reset y-velocity when on the floor

func handle_idle_and_random_animations(delta):
	# Increase timer to track when to play a random animation
	random_animation_time += delta

	if random_animation_time >= random_animation_interval:
		random_animation_time = 0.0  # Reset timer
		play_random_animation()  # Play a random animation

	if not is_playing_random_animation and !$AnimatedSprite2D.is_playing():
		# Play Idle only if no animation is currently playing
		$AnimatedSprite2D.play("Idle")

# Function to play a random animation
func play_random_animation():
	var random_index = randi() % animations.size()
	var chosen_animation = animations[random_index]

	# Play the random animation
	print("Playing random animation:", chosen_animation)
	$AnimatedSprite2D.play(chosen_animation)
	
	# Set the flag to indicate a random animation is playing
	is_playing_random_animation = true

	# Wait until the animation finishes before switching to Idle
	await $AnimatedSprite2D.animation_finished  # Use await for the animation
	is_playing_random_animation = false  # Reset the flag
	$AnimatedSprite2D.play("Idle")  # After finishing, switch to Idle
	
func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true


func _on_detection_area_body_exited(body: Node2D) -> void:
	player = null
	player_chase = false
	
func enemy():
	pass


func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_attack_zone = true


func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_attack_zone = false

func deal_with_damage():
	if player_in_attack_zone and Global.player_current_attack == true:
		if can_take_damage == true:
			health = health - 10
			$take_damage_cooldown.start()
			can_take_damage = false
			print("Slime health = ", health)
			if health <= 0:
				get_parent().queue_free()
		#Need to make it when the slime dies, it becomes disabled, have a timer, then enabled

func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true
