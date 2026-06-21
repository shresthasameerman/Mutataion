extends Control

@onready var label = $Label

const STORY = "The antidote works.\n\nThe mutation reverses.\n\n\"Marcus?\"\n\n\"...hey.\"\n\n\"You remember me?\"\n\n\"I always remembered you.\"\n\nYou both stumble out of the facility at dawn.\n\n\n[ENTER] Play Again        [ESC] Quit"

func _ready():
	label.text = ""
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var tween = create_tween()
	for i in STORY.length():
		tween.tween_callback(func(): label.text += STORY[i])
		tween.tween_interval(0.03)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		GameManager.reset_game()
		get_tree().change_scene_to_file("res://scenes/levels/test_level_1.tscn")
	elif event.is_action_pressed("ui_cancel"):
		get_tree().quit()
