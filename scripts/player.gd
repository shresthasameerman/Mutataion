extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.003
const MAX_HEALTH = 100.0
const DRAIN_RATE = 100.0 / 300.0  # drains fully in 30 min if untouched

@onready var camera = $Camera3D
@onready var ray = $RayCast3D
@onready var heartbeat = $HeartbeatAudio
@onready var interact_label = $Camera3D/InteractLabel
@onready var footstep_audio = $FootstepAudio 

var footstep_sounds = [
	preload("res://assets/sounds/freesound_community-concrete-footsteps-6752.mp3")
]
var footstep_timer = 0.0
const FOOTSTEP_INTERVAL = 0.4

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var health: float = MAX_HEALTH

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	interact_label.visible = false
	heartbeat.stream.loop = true
	heartbeat.play()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event.is_action_pressed("Interact"):
		_try_interact()

func _physics_process(delta):
	if not GameManager.game_active:
		return

	health -= DRAIN_RATE * delta
	health = clamp(health, 0, MAX_HEALTH)
	_check_mutation_stage()
	_update_heartbeat()
	if health <= 0:
		GameManager.player_died()

	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("Left","Right","Forward","Backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	_handle_footsteps(delta)
	_check_interactable()


func _handle_footsteps(delta):
	var moving = Vector2(velocity.x, velocity.z).length() > 0.5
	if moving and is_on_floor():
		footstep_timer -= delta
		if footstep_timer <= 0:
			footstep_timer = FOOTSTEP_INTERVAL
			footstep_audio.stream = footstep_sounds[randi() % footstep_sounds.size()]
			footstep_audio.pitch_scale = randf_range(0.9, 1.1)
			footstep_audio.play()
	else:
		footstep_timer = 0.0
		if footstep_audio.playing:
			footstep_audio.stop()
			
			

func _check_mutation_stage():
	var stage = 0
	if health < 30:
		stage = 2
	elif health < 60:
		stage = 1
	GameManager.notify_stage(stage)

func _check_interactable():
	if ray.is_colliding():
		var hit = ray.get_collider()
		if hit.has_method("interact"):
			interact_label.text = "[E]  " + hit.interact_hint
			interact_label.visible = true
			return
	interact_label.visible = false

func _try_interact():
	if ray.is_colliding():
		var hit = ray.get_collider()
		if hit.has_method("interact"):
			hit.interact()

func take_damage(amount: float):
	health -= amount
	health = clamp(health, 0, MAX_HEALTH)
	print("Player health: ", health)
	if health <= 0:
		GameManager.player_died()

func heal(amount: float):
	health += amount
	health = clamp(health, 0, MAX_HEALTH)
	print("Healed! Health: ", health)
	GameManager.flash_message("Antidote absorbed...")
	
func _update_heartbeat():
	var urgency = 1.0 - (health / MAX_HEALTH)
	var curved_urgency = pow(urgency, 1.5)  # ramps up faster near death, gentle at first
	heartbeat.volume_db = lerp(-22.0, 2.0, curved_urgency)
	heartbeat.pitch_scale = lerp(0.85, 1.6, curved_urgency)
