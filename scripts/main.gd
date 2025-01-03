extends Node
class_name Main

@export var mob_scene: PackedScene

# arrow delay
@export_range(1.0, 3.0) var start_delay: float = 2.0
@export_range(0.2, 1.0) var min_delay: float = 0.5
@export_range(0.001, 0.1) var delay_rate: float = 0.05

# speed multiplier
@export_range(0.5, 1.5) var base_multiplier: float = 1.0
@export_range(1.0, 5.0) var max_multiplier: float = 2.0
@export_range(0.02, 0.5) var speed_up_rate: float = 0.05
var current_multiplier: float = base_multiplier

@export_range(0.5, 1.5) var base_mob_wait_time: float = 0.5

@export_range(0.1, 1.0) var size_variance: float = 0.5
@export_range(0.75, 1.5) var max_size_multiplier: float = 1.0

var score: int

@onready var score_timer: Timer = $ScoreTimer
@onready var mob_timer: Timer = $MobTimer
@onready var player: Player = $Player
@onready var start_timer: Timer = $StartTimer
@onready var start_position: Marker2D = $StartPosition
@onready var ui: UI = $UI



func _ready() -> void:
	player.start(start_position.position)

func game_over():

	$Music.stop()
	$GameOver.play()

	current_multiplier = base_multiplier

	# find and freeze the remaining mobs
	var remaining_mobs = find_remaining_mobs()
	freeze_mobs(remaining_mobs)

	#stop the timers
	score_timer.stop()
	mob_timer.stop()

	# reset the ui
	await ui.show_game_over()

	# reset the board
	player.start(start_position.position)
	kill_mobs(remaining_mobs)

func new_game():
	$Music.play()
	score = 0
	ui.update_score(score)
	await ui.start_ui(start_timer.wait_time)
	start_timer.start()

func find_remaining_mobs() -> Array[Mob]:
	var remaining_mobs: Array[Mob] = []

	for child in get_children():
		if child is Mob:
			remaining_mobs.append(child)

	return remaining_mobs

func kill_mobs(mobs: Array[Mob]) -> void:
	for mob in mobs:
		if is_instance_valid(mob):
			mob.queue_free()

func freeze_mobs(mobs: Array[Mob]) -> void:
	for mob in mobs:
		mob.freeze_()

func calculate_delay(score_: int) -> float:
	return max(min_delay, start_delay - (0.5 * score_ * delay_rate))

func calculate_speed_multiplier(score_: int) -> float:
	return min(max_multiplier, base_multiplier + (0.5 * score_ * speed_up_rate))

func calculate_scale(multiplier_) -> Vector2:
	var variance_multiplier = randf_range(1.0 - size_variance, 1.0 + size_variance)
	return Vector2.ONE * min(max_size_multiplier, multiplier_ * 0.75) * variance_multiplier

func create_mob(mob_spawn_location: PathFollow2D = $MobPath/MobSpawnLocation) -> void:
	# determine values for mob
	mob_spawn_location.progress_ratio = randf()

	var direction = mob_spawn_location.rotation + PI/2
	direction += randf_range(-PI/4, PI/4)

	var velocity = 1.1 * current_multiplier * Vector2(randf_range(150.0, 250.0), 0.0)
	var angled_velocity = velocity.rotated(direction)

	#var mob: Mob = mob_scene.instantiate().with_data(mob_spawn_location.position, direction, angled_velocity)
	var mob: Mob = mob_scene.instantiate()
	add_child(mob)
	mob.has_died.connect(_on_mob_died)

	mob.create(angled_velocity, direction, mob_spawn_location.position, calculate_delay(score), calculate_scale(current_multiplier))

#region signal_functions
func _on_player_hit() -> void:
	game_over()

func _on_mob_died() -> void:
	score += 1
	current_multiplier = calculate_speed_multiplier(score)
	mob_timer.wait_time = base_mob_wait_time * (1/ (2.0 * base_multiplier))
	ui.update_score(score)

func _on_mob_timer_timeout() -> void:
	create_mob()

func _on_start_timer_timeout() -> void:
	mob_timer.start()
	score_timer.start()
#endregion

func _on_ui_start_game() -> void:
	new_game()
