extends Node3D


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if Input.is_key_pressed(KEY_R):
		get_tree().reload_current_scene()
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()
		if event.pressed and event.keycode == KEY_E:
			if (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			elif (Input.mouse_mode == Input.MOUSE_MODE_VISIBLE):
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
