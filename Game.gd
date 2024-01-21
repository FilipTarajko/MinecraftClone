extends Node3D

@onready var world = $World

@export var block_types: Array[Block_Resource]
var blocks: Array[PhysicsBody3D] = []
var name_to_index_dictionary = {}
var commonly_spawned_blocks_indexes = []
var obtainable_blocks_indexes = []

var static_block = preload("res://static_block.tscn")
var rigidbody_block = preload("res://rigidbody_block.tscn")

var base_block_mesh = preload("res://blocks/base_block_mesh.tres")
var transparent_block_mesh = preload("res://blocks/transparent_block_mesh.tres")
var i = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var index = 0
	for block_type in block_types:
		var new_block
		if block_type.gravity:
			new_block = rigidbody_block.duplicate(true).instantiate()
		else:
			new_block = static_block.duplicate(true).instantiate()
		if block_type.transparent:
			new_block.get_node("MeshInstance3D").mesh = transparent_block_mesh.duplicate(true)
		else:
			new_block.get_node("MeshInstance3D").mesh = base_block_mesh.duplicate(true)
		new_block.get_node("MeshInstance3D").mesh.material.albedo_texture = block_type.image
		blocks.push_back(new_block.duplicate(true))
		name_to_index_dictionary[block_type.name] = index
		if block_type.commonly_spawned:
			commonly_spawned_blocks_indexes.push_back(index)
		if block_type.obtainable:
			obtainable_blocks_indexes.push_back(index)
		index += 1
	print(blocks)
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
