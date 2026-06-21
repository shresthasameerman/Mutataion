extends StaticBody3D

var interact_hint = "Open Door"
var is_open = false
var is_animating = false
@onready var door_sound = $DoorSound  # add AudioStreamPlayer3D child
@export var locked = false
@export var required_doses = 0  # 0 = unlocked, 1/2 = needs doses



func interact():
	if is_animating:
		return
	if locked:
		_try_unlock()
		return
	if is_open:
		_close()
	else:
		_open()

func _try_unlock():
	if GameManager.doses_collected >= required_doses:
		locked = false
		interact_hint = "Open Door"
		_open()
	else:
		# door is locked — show hint
		interact_hint = "Locked (Need " + str(required_doses) + " doses)"

func _open():
	is_open = true
	is_animating = true
	interact_hint = "Close Door"
	door_sound.play()
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y + 3.0, 1.0)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func(): is_animating = false)
	$CollisionShape3D.set_deferred("disabled", true)

func _close():
	is_open = false
	is_animating = true
	interact_hint = "Open Door"
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 3.0, 1.0)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func(): 
		is_animating = false
		$CollisionShape3D.set_deferred("disabled", false))
