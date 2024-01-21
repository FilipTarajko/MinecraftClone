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
	return game.transparent_blocks_indexes.has(blocks[x-1][y][z]) || game.transparent_blocks_indexes.has(blocks[x+1][y][z]) \
		|| game.transparent_blocks_indexes.has(blocks[x][y-1][z]) || game.transparent_blocks_indexes.has(blocks[x][y+1][z]) \
		|| game.transparent_blocks_indexes.has(blocks[x][y][z-1]) || game.transparent_blocks_indexes.has(blocks[x][y][z+1]) 


func check_neighboring_blocks_visibilities(x, y, z):
	return [
		x>0 && check_if_any_face_visible(x-1, y, z),
		x<platform_lenght-1 && check_if_any_face_visible(x+1, y, z),
		y>0 && check_if_any_face_visible(x, y-1, z),
		y<max_height-1 && check_if_any_face_visible(x, y+1, z),
		z>0 && check_if_any_face_visible(x, y, z-1),
		z<platform_lenght-1 && check_if_any_face_visible(x, y, z+1),
	]


func handle_destroy_block(block):
	var x = block.position.x
	var y = block.position.y
	var z = block.position.z
	var particles = game.block_broken_particles.instantiate()
	particles.material_override = block.get_node("MeshInstance3D").mesh.material
	particles.position = block.position
	particles.emitting = true
	add_child(particles)
	var neighboring_visilities_before = check_neighboring_blocks_visibilities(x, y, z)
	print(neighboring_visilities_before)
	blocks[x][y][z] = 0
	var neighboring_visilities_after = check_neighboring_blocks_visibilities(x, y, z)
	for i in range(6):
		if !neighboring_visilities_before[i] && neighboring_visilities_after[i]:
			match i:
				0:
					create_mesh_and_collider(x-1, y, z)
				1:
					create_mesh_and_collider(x+1, y, z)
				2:
					create_mesh_and_collider(x, y-1, z)
				3:
					create_mesh_and_collider(x, y+1, z)
				4:
					create_mesh_and_collider(x, y, z-1)
				5:
					create_mesh_and_collider(x, y, z+1)
	print(neighboring_visilities_after)
	var raycast = game.block_destroyed_raycast.instantiate()
	raycast.block_destroyed_raycast = game.block_destroyed_raycast
	raycast.world = self
	raycast.position = block.position
	add_child(raycast)
	block.queue_free()


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


func place_and_save_obtainable_block(new_block_position):
	var block_index = game.obtainable_blocks_indexes.pick_random()
	blocks[new_block_position.x][new_block_position.y][new_block_position.z] = block_index
	var placed_block = place_block(new_block_position, block_index)
	if placed_block is RigidBody3D:
		placed_block.freeze = false


func place_commonly_spawned_block(new_block_position):
	place_block(new_block_position, game.commonly_spawned_blocks_indexes.pick_random())


func place_bedrock(new_block_position):
	place_block(new_block_position, game.name_to_index_dictionary["bedrock"])
