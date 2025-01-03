extends Button
class_name StartButton

func _process(_delta):

	if Input.is_action_pressed("ui_accept") and visible:
		pressed.emit()
