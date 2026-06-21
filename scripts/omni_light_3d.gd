extends OmniLight3D

func _ready():
	_flicker()

func _flicker():
	await get_tree().create_timer(randf_range(0.05, 0.3)).timeout
	light_energy = randf_range(0.4, 1.0)
	_flicker()
