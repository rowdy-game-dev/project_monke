extends Control

# Written following https://youtu.be/JEQR4ALlwVU?si=_blJ9-LVY7T5CGhr

@onready var main = $"../../"

func _on_resume_pressed() -> void:
	main.pauseMenu()

func _on_quit_pressed() -> void:
	get_tree().quit()
