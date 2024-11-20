extends CharacterBody2D

const MAX_HEALTH_POINTS = 40
var health_points = MAX_HEALTH_POINTS

var walk_direction = 1.0

@onready var main_hitbox := $main_hitbox
@onready var agro_area := $agro_area

func _ready() -> void:
    pass

func _process(delta: float) -> void:
    _move_toward_player(delta)
    _handle_jump(delta)
    

    if walk_direction != 0:
        $AnimatedSprite2D.flip_h = false if walk_direction > 0 else true
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

func take_damage(damage: int):
    health_points -= damage
    

    if health_points <= 0:
        kill()
    else:
        hit_animation()

func hit_animation():
    $GPUParticles2D.amount = 10
    $GPUParticles2D.restart()
    
func kill():
    $AnimatedSprite2D.visible = false
    $main_hitbox.free()
    $GPUParticles2D.amount = 50
    $GPUParticles2D.restart()
    $GPUParticles2D.finished.connect(func():
        queue_free()
    )
    

func _move_toward_player(delta):
    for body in agro_area.get_overlapping_bodies():
        if body.name == "player":
            walk_direction = sign(body.global_position.x - global_position.x)
            velocity.x = move_toward(velocity.x,
            50 * walk_direction,
            150 * delta)

func _gravity(delta):
    if not is_on_floor():
        velocity += get_gravity() * delta