extends CanvasLayer
class_name UI

signal start_game

@onready var message_label: RichTextLabel = $MessageLabel
@onready var message_timer: Timer = $MessageTimer
@onready var start_button: Button = $StartButton
@onready var score_label: Label = $ScoreLabel
@onready var title: RichTextLabel = $Title

const MESSAGE_DICT: Dictionary = {
	GAMEOVER = "[center]Game Over[center]",
	DODGE = "[wave][center]Dodge the Creeps![/center][/wave]",
	START = "[center]Go![center]"
}

const M = MESSAGE_DICT

@export_range(1, 5) var countdown_start: int = 2

func count_down(label, starting_number = countdown_start) -> void:
	for i in range(starting_number, 0, -1):
		label.text = "[center]%s[center]" % str(i)
		label.show()
		await get_tree().create_timer(1.0).timeout

func show_message(text, label, wait_timer = 2) -> void:
	label.text = text
	label.show()
	message_timer.start(wait_timer)

func show_game_over() -> void:
	show_message(M.GAMEOVER, message_label)
	await message_timer.timeout

	title.show()

	await get_tree().create_timer(1.0).timeout
	start_button.show()

func update_score(score) -> void:
	score_label.text = str(score)

func start_ui(start_delay = 0.5, label = message_label) -> void:
	title.hide()
	start_button.hide()
	await count_down(label)
	show_message(M.START, label, start_delay)
	score_label.show()


func _on_start_button_pressed() -> void:
	start_game.emit()

func _on_message_timer_timeout() -> void:
	message_label.hide()

func _on_pause_has_paused() -> void:
	$PauseLabel.visible = not $PauseLabel.visible
