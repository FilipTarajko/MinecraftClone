extends Label

@export var player: Node3D
var disabled = false

func _process(_delta):
	if (Input.is_action_just_pressed("toggle_raycast_tooltip")):
		disabled = !disabled
	if (!disabled):
		var label_text
		if player.raycasted_object_name:
			label_text = "Block:\n"+player.raycasted_object_name
		else:
			label_text = ""
		set_text(label_text)
	else:
		set_text("")
