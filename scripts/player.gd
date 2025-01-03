extends Area2D
class_name Player

signal hit

@export var speed = 400
var screen_size

var direction = Vector2.ZERO
var velocity = Vector2.ZERO

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: CollisionShape2D = $CollisionShape2D
@onready var player_size: Vector2 = hitbox.shape.get_rect().size

func start(pos: Vector2):
	position = pos
	show()
	hitbox.disabled = false

func _ready() -> void:
	screen_size = get_viewport_rect().size
	sprite.animation = "up"
	#hide()

func _on_body_entered(_body: Node2D) -> void:
	hide()
	hit.emit()
	hitbox.set_deferred("disabled", true)

func _process(delta) -> void:

	velocity = Vector2.ZERO
	direction = Vector2.ZERO

	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	if Input.is_action_pressed("move_up"):
		direction.y -= 1


	if direction.length() > 0:
		velocity = direction.normalized() * speed
		sprite.play()

		sprite.rotation = direction.angle()
		hitbox.rotation = direction.angle()
	else:
		sprite.stop()

	position += velocity * delta
	position = position.clamp(Vector2.ZERO + 0.5*player_size, screen_size - 0.5*player_size)
