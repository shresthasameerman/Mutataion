extends CanvasLayer

@onready var health_bar = $Control/HealthBar
@onready var dose_label = $Control/DoseLabel
@onready var vignette = $Control/Vignette
@onready var warn_label = $Control/WarnLabel

var player: Node

func _ready():
	GameManager.mutation_stage_changed.connect(_on_stage_change)
	GameManager.show_message.connect(_on_show_message)
	GameManager.game_over.connect(_on_game_over)
	vignette.color = Color(0.8, 0, 0, 0)
	warn_label.text = ""
	player = get_tree().get_first_node_in_group("player")

func _process(_delta):
	dose_label.text = "Doses: " + str(GameManager.doses_collected) + " / 3"
	if player:
		health_bar.value = player.health

func _on_stage_change(stage):
	match stage:
		0:
			vignette.color = Color(0.8, 0, 0, 0)
		1:
			var tween = create_tween().set_loops()
			tween.tween_property(vignette, "color:a", 0.2, 1.0)
			tween.tween_property(vignette, "color:a", 0.0, 1.0)
		2:
			vignette.color = Color(0.8, 0, 0, 0.35)

func _on_show_message(text: String):
	warn_label.text = text
	await get_tree().create_timer(1.5).timeout
	if warn_label.text == text:
		warn_label.text = ""

func _on_game_over(won):
	print("GAME OVER signal received — won = ", won)
	if won:
		get_tree().change_scene_to_file("res://scenes/ui/end_good.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/ui/end_bad.tscn")
