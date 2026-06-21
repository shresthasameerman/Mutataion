# syringe.gd
extends Area3D
@onready var pickup_sound = $PickupSound

var bob_tween: Tween

func _ready():
	bob_tween = create_tween().set_loops()
	bob_tween.tween_property(self, "position:y", position.y + 0.2, 0.8)
	bob_tween.tween_property(self, "position:y", position.y, 0.8)

func stop_bobbing():
	if bob_tween:
		bob_tween.kill()

func _process(_delta):
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			GameManager.collect_dose()
			pickup_sound.play()
			visible = false
			set_process(false)
			monitoring = false
			await pickup_sound.finished
			queue_free()
			return   # ← stop iterating the rest of get_overlapping_bodies() this frame
