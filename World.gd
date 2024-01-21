extends Node3D

@export var game: Node3D
@export var blocks: Node3D
@export var rigidbody_script: Script
var platform_lenght = 17
var platform_depth = 17


func place_block(new_block_position, index):
	var new_block = game.blocks[index].duplicate(false)
	if new_block is RigidBody3D:
		new_block.set_script(rigidbody_script)
	new_block.position = new_block_position
	new_block.name = game.blocks[index].name
	blocks.add_child(new_block)
	return new_block


func place_obtainable_block(new_block_position):
	var placed_block = place_block(new_block_position, game.obtainable_blocks_indexes.pick_random())
	if placed_block is RigidBody3D:
		placed_block.freeze = false


func place_commonly_spawned_block(new_block_position):
	place_block(new_block_position, game.commonly_spawned_blocks_indexes.pick_random())


func place_bedrock(new_block_position):
	place_block(new_block_position, game.name_to_index_dictionary["bedrock"])


func generate_terrain():
	print("volume: "+str((platform_lenght)*(platform_lenght)*(platform_depth-1)))
	for i in range(platform_lenght):
		for j in range(platform_lenght):
			for k in range(platform_depth-1):
				place_commonly_spawned_block(Vector3(i, -k, j))
			place_bedrock(Vector3(i, -platform_depth, j))
