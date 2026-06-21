extends CharacterBody3D
enum State { PATROL, CHASE }
const ANIM_IDLE = "Armature|Armature|Armature|Armature|IdleComplete"
const ANIM_WALK = "Walk_InPlace"
const ANIM_RUN  = "Run_InPlace"
@export var speed_patrol = 1.5
@export var speed_chase = 3.5
@export var detection_range = 8.0
@export var wander_radius = 6.0
@onready var growl_sound = $GrowlSound
@onready var anim_player: AnimationPlayer = find_child("AnimationPlayer", true, false)
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
var state = State.PATROL
var player: Node3D
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var speed_multiplier = 1.0
var can_catch = true
var current_anim = ""
var start_position: Vector3
var repath_timer = 0.0
var growl_timer = 0.0
var is_recovering = false   # true briefly after landing a hit — enemy holds still, giving the player room to run

func _ready():
	player = get_tree().get_first_node_in_group("player")
	GameManager.mutation_stage_changed.connect(_on_mutation_stage)
	_play_anim(ANIM_IDLE)
	start_position = global_position
	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = 0.5
	await get_tree().physics_frame
	_pick_new_wander_point()

func _play_anim(anim_name: String):
	if anim_player and current_anim != anim_name:
		current_anim = anim_name
		anim_player.play(anim_name)

func _on_mutation_stage(stage):
	match stage:
		1: speed_multiplier = 1.3
		2: speed_multiplier = 1.7

func _play_growl():
	growl_sound.pitch_scale = randf_range(0.75, 1.35)
	growl_sound.volume_db = randf_range(-3.0, 1.0)
	growl_sound.play()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	var dist = global_position.distance_to(player.global_position)
	var new_state = State.CHASE if dist < detection_range else State.PATROL
	if new_state != state:
		state = new_state
		if state == State.CHASE:
			_play_anim(ANIM_RUN)
			_play_growl()
			growl_timer = randf_range(3.0, 6.0)
		else:
			_play_anim(ANIM_WALK)
			_pick_new_wander_point()
	if state == State.CHASE:
		growl_timer -= delta
		if growl_timer <= 0:
			_play_growl()
			growl_timer = randf_range(3.0, 6.0)
	match state:
		State.CHASE:
			nav_agent.target_position = player.global_position
		State.PATROL:
			repath_timer -= delta
			if nav_agent.is_navigation_finished() or repath_timer <= 0:
				_pick_new_wander_point()
	if is_recovering:
		velocity.x = 0
		velocity.z = 0
	else:
		_move_along_path()
	move_and_slide()
	if dist < 1.2 and can_catch and GameManager.can_enemy_attack():
		_catch_player()

func _move_along_path():
	if nav_agent.is_navigation_finished():
		velocity.x = 0
		velocity.z = 0
		return
	var next_pos = nav_agent.get_next_path_position()
	var dir = (next_pos - global_position)
	dir.y = 0
	dir = dir.normalized()
	var current_speed = speed_chase * speed_multiplier if state == State.CHASE else speed_patrol
	velocity.x = dir.x * current_speed
	velocity.z = dir.z * current_speed
	if dir.length() > 0.1:
		look_at(global_position + dir, Vector3.UP)

func _pick_new_wander_point():
	repath_timer = randf_range(4.0, 8.0)
	var random_point = start_position + Vector3(
		randf_range(-wander_radius, wander_radius),
		0,
		randf_range(-wander_radius, wander_radius)
	)
	var map = get_world_3d().navigation_map
	var safe_point = NavigationServer3D.map_get_closest_point(map, random_point)
	nav_agent.target_position = safe_point

func _catch_player():
	can_catch = false
	is_recovering = true
	var dmg = GameManager.get_adaptive_catch_damage()
	player.take_damage(dmg)
	_play_anim(ANIM_IDLE)
	if not is_inside_tree():
		return
	await get_tree().create_timer(1.5).timeout
	if not is_inside_tree():
		return
	is_recovering = false
	can_catch = true
	if state == State.CHASE:
		_play_anim(ANIM_RUN)
