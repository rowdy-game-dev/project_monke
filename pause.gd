extends Node

# Written following https://youtu.be/JEQR4ALlwVU?si=_blJ9-LVY7T5CGhr

@onready var pause_menu: Control = $camera/PauseMenu
var paused = false

func _ready():
	pause_menu.hide();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("pause"):
		pauseMenu()
	
func pauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
	
	paused = !paused
