extends RigidBody2D
class_name Mob

signal has_died

const RED_ARROW = preload("res://art/arrow_red.png")

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox : CollisionShape2D = $CollisionShape2D
@onready var arrow: Sprite2D = $Arrow
@onready var delay_timer: Timer = $DelayTimer

@export var high_speed: float = 425.0

var frozen: bool = false

#func with_data(spawn_location: Vector2, rotation_: float, velocity: Vector2):
	## ask chatgpt why self.rotation.set_deferred doesnt work
	## https://www.reddit.com/r/godot/comments/13pm5o5/instantiating_a_scene_with_constructor_parameters/
	#self.set_deferred("rotation", rotation_)
	#self.set_deferred("position", spawn_location)
	#self.set_deferred("linear_velocity", velocity)

func pause_animation() -> void:
	sprite.pause()

func freeze_() -> void:
	frozen = true
	sprite.pause()
	linear_velocity = Vector2.ZERO

func unfreeze() -> void:
	frozen = false
	sprite.play()

func apply_scales(scale_: Vector2, children: Array[Node]) -> void:
	for child in children:
		if child is Node2D:
			child.apply_scale(scale_)

func create(linear_velocity_: Vector2, rotation_: float, position_: Vector2, delay: float = 1.0, size_scale: Vector2 = Vector2.ONE) -> void:
	# mob sprite is initially just an arrow
	rotation = rotation_
	position = position_

	# make high speed arrows red
	if linear_velocity_.length_squared() > high_speed**2:
		arrow.texture = RED_ARROW

	# scale the sprites
	apply_scales(size_scale, get_children())

	# set timers
	delay_timer.wait_time = delay
	delay_timer.start()

	# set off approach animation
	await get_tree().create_timer(delay-0.5).timeout
	$AnimationPlayer.play("approach")
	$AnimationPlayer.advance(0)

	# wait for delay timer to finish
	await delay_timer.timeout


	# unleash the mob
	if not frozen:
		hitbox.disabled = false
		sprite.show()
		linear_velocity = linear_velocity_

func _ready() -> void:
	var mob_types = sprite.sprite_frames.get_animation_names()
	sprite.play(mob_types[randi()% mob_types.size()])

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	has_died.emit()
