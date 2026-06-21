extends StaticBody3D

@export var correct_code: String = "742"
@export var anim_name: String = "Antique_Safe_BONES|Antique_Safe_BONESAction"
@export var locker_drain_rate: float = 4.0  # health per second while cracking the safe

var interact_hint = "Enter code"
var is_unlocked = false
var is_ui_open = false
var player_ref: Node = null

@onready var keypad_ui = $KeypadUI
@onready var code_input = $KeypadUI/Control/CodeInput
@onready var submit_btn = $KeypadUI/Control/SubmitBtn
@onready var cancel_btn = $KeypadUI/Control/CancelBtn
@onready var anim_player: AnimationPlayer = get_parent().find_child("AnimationPlayer", true, false)
@onready var syringe = $syringe

func _ready():
	keypad_ui.visible = false
	submit_btn.pressed.connect(_on_submit_pressed)
	cancel_btn.pressed.connect(_close_keypad)
	code_input.text_submitted.connect(func(_t): _on_submit_pressed())

	if syringe:
		syringe.visible = false
		syringe.set_process(false)
		if syringe is Area3D:
			syringe.monitoring = false

func interact():
	if is_unlocked or is_ui_open:
		return
	_open_keypad()

func _open_keypad():
	is_ui_open = true
	keypad_ui.visible = true
	code_input.text = ""
	code_input.grab_focus()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	player_ref = get_tree().get_first_node_in_group("player")
	if player_ref:
		player_ref.set_physics_process(false)
	GameManager.set_player_busy(true)

func _close_keypad():
	is_ui_open = false
	keypad_ui.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if player_ref:
		player_ref.set_physics_process(true)
	GameManager.set_player_busy(false)
	
func _process(delta):
	if is_ui_open and player_ref and GameManager.game_active:
		player_ref.take_damage(locker_drain_rate * delta)

func _on_submit_pressed():
	if code_input.text == correct_code:
		_unlock()
	else:
		code_input.text = ""
		code_input.placeholder_text = "Wrong code — try again"

func _unlock():
	is_unlocked = true
	_close_keypad()
	if anim_player and anim_player.has_animation(anim_name):
		anim_player.play(anim_name)
	if syringe:
		syringe.visible = true
		syringe.set_process(true)
		if syringe is Area3D:
			syringe.monitoring = true
		await get_tree().create_timer(0.6).timeout
		if syringe.has_method("stop_bobbing"):
			syringe.stop_bobbing()
		_slide_syringe_out()

func _slide_syringe_out():
	var start_pos = syringe.position
	var target_pos = start_pos + Vector3(0, 0.3, 1.5)  # forward + slightly up
	var tween = create_tween()
	tween.tween_property(syringe, "position", target_pos, 1.0)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _input(event):
	if is_ui_open and event.is_action_pressed("ui_cancel"):
		_close_keypad()
