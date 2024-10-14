extends CharacterBody2D

var speed = 50
const GRAVITY = 900.0
var player_chase = false
var player = null
var health = 100
var player_in_attack_zone = false

func _physics_process(delta):
	
	deal_with_damage()
	
	if player_chase:
		position.x =  move_toward(position.x, player.position.x, speed * delta)
		move_and_collide(Vector2(0,0))
		
		$AnimatedSprite2D.play("Walk")
		
		if(player.position.x - position.x) < 0:
			$AnimatedSprite2D.flip_h = (position > player.position)
	else:
		$AnimatedSprite2D.play("Idle")
		
	# Apply gravity if not on the floor
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0  # Reset y-velocity when on the floor

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
		health = health - 10
		print("Slime health = ", health)
		#Need to make it when the slime dies, it becomes disabled, have a timer, then enabled
