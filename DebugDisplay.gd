extends Label

@onready var player = $"../../Player"
var disabled = false

func _process(delta):
	if (Input.is_action_just_pressed("toggle_debug_data")):
		disabled = !disabled
	if (!disabled):
		var text = "FPS %d" % Engine.get_frames_per_second() + "\n"
		text += "XYZ: " + str(snapped(player.position, Vector3(0.1,0.1,0.1))) + "\n"
		text += "deg rotation.y: " + str(snapped(rad_to_deg(player.camera_stick.rotation.y), 1))
		set_text(text)
	else:
		set_text("")
