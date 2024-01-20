extends Node3D

@onready var world = $World

@export var blocks: Array[Block_Resource]
var meshes: Array[BoxMesh]
var base_block_mesh = preload("res://blocks/base_block_mesh.tres")


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	for block in blocks:
		var new_mesh = base_block_mesh.duplicate(true)
		new_mesh.material.albedo_texture = block.image
		meshes.push_back(new_mesh)
	world.generate_terrain()


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
	if event.is_action_pressed("toggle_fullscreen"):
		swap_fullscreen_mode()


func swap_fullscreen_mode():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
