extends Node3D

@export var game: Node3D
@export var blocks_object: Node3D
@export var rigidbody_script: Script
var platform_lenght = 17
var platform_height = 17
var max_height = 30

var blocks = []


func _physics_process(delta):
	if Input.is_action_just_pressed("regenerate_chunks"):
		blocks_object.queue_free()
		blocks_object = Node3D.new()
		add_child(blocks_object)
		generate_terrain()


func generate_terrain():
	for x in range(platform_lenght):
		blocks.push_back([])
		for y in range(max_height):
			blocks[x].push_back([])
			for z in range(platform_lenght):
				var block = 0 # air
				if y == 0:
					block = 1 # bedrock
				elif y < platform_height/2:
					#block = 2 # stone
					block = game.obtainable_blocks_indexes.pick_random()
				elif y < platform_height:
					block = 3 # dirt
				elif y == platform_height:
					block = 4 # grass
				blocks[x][y].push_back(block)
	draw_blocks()


func create_mesh_and_collider(x, y, z):
	place_block(Vector3(x, y, z), blocks[x][y][z])


func draw_blocks():
	for x in range(platform_lenght):
		for y in range(max_height):
			for z in range(platform_lenght):
				if check_if_any_face_visible(x, y, z):
					create_mesh_and_collider(x, y, z)


func check_if_any_face_visible(x, y, z):
	if blocks[x][y][z] == 0:
		return false
	if x == 0 || x == platform_lenght-1 || y == 0 || y == max_height || z == 0 || z == platform_lenght - 1:
		return true
	return blocks[x-1][y][z]==0 || blocks[x+1][y][z]==0 || blocks[x][y-1][z]==0 || blocks[x][y+1][z]==0 || blocks[x][y][z-1]==0 || blocks[x][y][z+1]==0 


func place_block(new_block_position, index):
	if !index:
		return
	var new_block = game.blocks[index].duplicate(false)
	if new_block is RigidBody3D:
		new_block.set_script(rigidbody_script)
	new_block.position = new_block_position
	new_block.name = game.blocks[index].name
	blocks_object.add_child(new_block)
	
	
	return new_block


func place_obtainable_block(new_block_position):
	var placed_block = place_block(new_block_position, game.obtainable_blocks_indexes.pick_random())
	if placed_block is RigidBody3D:
		placed_block.freeze = false


func place_commonly_spawned_block(new_block_position):
	place_block(new_block_position, game.commonly_spawned_blocks_indexes.pick_random())


func place_bedrock(new_block_position):
	place_block(new_block_position, game.name_to_index_dictionary["bedrock"])
