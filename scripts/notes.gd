extends StaticBody3D

@export var note_text: String = "084   742   519\n963   086   201"
@export var fall_target_y: float = 0.05  # ← set this to your actual floor height

var interact_hint = "Read note"
var is_open = false
var player_ref: Node = null

@onready var note_ui = $NoteUI
@onready var text_label = $NoteUI/Control/Panel/TextLabel
@onready var close_btn = $NoteUI/Control/Panel/CloseBtn

func _ready():
	note_ui.visible = false
	close_btn.pressed.connect(_close_note)
	text_label.text = note_text
	_drop_to_floor()

func _drop_to_floor():
	var start_pos = global_position
	var target_pos = Vector3(start_pos.x, fall_target_y, start_pos.z)
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_pos, 0.6)\
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "rotation:z", randf_range(-0.3, 0.3), 0.6)

func interact():
	if is_open:
		return
	_open_note()

func _open_note():
	is_open = true
	note_ui.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	player_ref = get_tree().get_first_node_in_group("player")
	if player_ref:
		player_ref.set_physics_process(false)

func _close_note():
	is_open = false
	note_ui.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if player_ref:
		player_ref.set_physics_process(true)

func _input(event):
	if is_open and event.is_action_pressed("ui_cancel"):
		_close_note()
