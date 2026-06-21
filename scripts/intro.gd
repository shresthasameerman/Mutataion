extends Control

@onready var story_label = $StoryLabel
@onready var controls_label = $ControlsLabel
@onready var prompt_label = $PromptLabel

const STORY = "You woke up in Quarantine Wing 7.\n\nSomething bit you during the breach.\n\nYour friend Marcus... he's not himself anymore.\n\nFind 3 doses of the antidote before the mutation takes you completely.\n\nHe's hunting you now."

const CONTROLS_TEXT = "CONTROLS\n\nWASD — Move        Mouse — Look\nSPACE — Jump        E — Interact\nESC — Free cursor"

var typing_done = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	story_label.text = ""
	controls_label.text = CONTROLS_TEXT
	controls_label.visible = false
	prompt_label.text = "[ Press ENTER to begin ]"
	prompt_label.visible = false

	var tween = create_tween()
	for i in STORY.length():
		tween.tween_callback(func(): story_label.text += STORY[i])
		tween.tween_interval(0.02)
	tween.tween_callback(_show_controls)

func _show_controls():
	controls_label.visible = true
	prompt_label.visible = true
	typing_done = true

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if typing_done:
			get_tree().change_scene_to_file("res://scenes/levels/test_level_1.tscn")
		else:
			# skip typewriter if player presses Enter early
			story_label.text = STORY
			_show_controls()
			
			
			
			
