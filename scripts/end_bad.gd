extends Control

@onready var label = $Label

const STORY = "The timer reaches zero.\n\nThe mutation is complete.\n\nYou are no longer yourself.\n\nMarcus and you both are mutated.\n\n.\n\n\n[Press ENTER to restart]"

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
