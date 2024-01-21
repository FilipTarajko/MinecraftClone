extends Label

@export var player: Node3D
var disabled = false

func _process(_delta):
	if (Input.is_action_just_pressed("toggle_debug_data")):
		disabled = !disabled
	if (!disabled):
		var label_text = "FPS %d" % Engine.get_frames_per_second() + "\n"
		label_text += "XYZ: " + str(snapped(player.position, Vector3(0.1,0.1,0.1))) + "\n"
		label_text += "deg rotation.y: " + str(snapped(rad_to_deg(player.camera_stick.rotation.y), 1))
		set_text(label_text)
	else:
		set_text("")
