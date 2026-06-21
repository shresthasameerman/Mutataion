extends Area3D
var can_damage = true

func _ready():
	body_entered.connect(_on_hurt)

func _on_hurt(body):
	if not is_inside_tree():
		return
	if body.is_in_group("player") and can_damage:
		can_damage = false
		body.take_damage(10)
		if not is_inside_tree():
			return
		await get_tree().create_timer(1.5).timeout
		if is_inside_tree():
			can_damage = true
