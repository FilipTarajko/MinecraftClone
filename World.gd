extends Node3D

@onready var game = $".."
var block_to_place = preload("res://block.tscn")
var platform_range = 8
var platform_depth = 16

func place_block(new_block_position):
	var new_block = block_to_place.instantiate()
	new_block.get_node("MeshInstance3D").mesh = game.meshes[randi() % len(game.meshes)]
	new_block.position = new_block_position
	add_child(new_block)

func generate_terrain():
	print("volume: "+str((2*platform_range+1)*(2*platform_range+1)*platform_depth))
	for i in range(2*platform_range+1):
		for j in range(2*platform_range+1):
			for k in range(platform_depth):
				place_block(Vector3(i-platform_range, -k, j-platform_range))
