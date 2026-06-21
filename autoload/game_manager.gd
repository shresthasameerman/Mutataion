extends Node

signal mutation_stage_changed(stage)
signal game_over(won)
signal show_message(text)

var doses_collected: int = 0
var mutation_stage: int = 0
var game_active: bool = true
var death_count: int = 0   # tracks how many times player has died, persists across restarts

var player_busy: bool = false        # true while player is in a UI interaction (safe, etc) — enemy can't attack
var attack_immunity_timer: float = 0.0   # seconds of safety after leaving a busy state

const HEAL_AMOUNT = 30.0

func _process(delta):
	if attack_immunity_timer > 0:
		attack_immunity_timer -= delta

func collect_dose():
	doses_collected += 1
	print("Dose collected! Total: ", doses_collected)
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.heal(HEAL_AMOUNT)
	if doses_collected >= 3:
		game_active = false
		emit_signal("game_over", true)

func flash_message(text: String):
	emit_signal("show_message", text)

func notify_stage(stage: int):
	if stage != mutation_stage:
		mutation_stage = stage
		emit_signal("mutation_stage_changed", stage)

func player_died():
	if game_active:
		game_active = false
		death_count += 1
		emit_signal("game_over", false)

func set_player_busy(value: bool):
	player_busy = value
	if not value:
		attack_immunity_timer = 1.5   # grace period before enemy can land a hit again

func can_enemy_attack() -> bool:
	return not player_busy and attack_immunity_timer <= 0

func get_adaptive_catch_damage() -> float:
	var base_damage = 20.0
	var mercy_reduction = death_count * 4.0
	var safes_beyond_first = max(0, doses_collected - 1)
	var progress_bonus = safes_beyond_first * 12.0
	var final_damage = base_damage - mercy_reduction + progress_bonus
	return clamp(final_damage, 8.0, 35.0)

func reset_game():
	doses_collected = 0
	mutation_stage = 0
	game_active = true
	player_busy = false
	attack_immunity_timer = 0.0
	# death_count is NOT reset here — it needs to persist across restarts!
