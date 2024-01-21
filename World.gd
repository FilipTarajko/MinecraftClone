extends Node3D

@onready var game = $".."
var platform_range = 8
var platform_depth = 16

func place_block(new_block_position):
	var new_block = game.blocks[randi() % len(game.blocks)].duplicate(false)
	new_block.position = new_block_position
	add_child(new_block)

func place_bedrock(new_block_position):
	var new_block = game.blocks[0].duplicate(false)
	new_block.position = new_block_position
	add_child(new_block)

func generate_terrain():
	print("volume: "+str((2*platform_range+1)*(2*platform_range+1)*platform_depth))
	for i in range(2*platform_range+1):
		for j in range(2*platform_range+1):
			for k in range(platform_depth):
				place_block(Vector3(i-platform_range, -k, j-platform_range))
			place_bedrock(Vector3(i-platform_range, -platform_depth, j-platform_range))
