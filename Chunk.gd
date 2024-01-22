extends Node3D

var game: Node3D
@export var blocks_object: Node3D
@export var rigidbody_script: Script
var chunk_offset_x: int
var chunk_offset_z: int

var blocks = []


func _physics_process(_delta):
	if Input.is_action_just_pressed("regenerate_chunks"):
		blocks_object.queue_free()
		blocks_object = Node3D.new()
		add_child(blocks_object)
		generate_terrain()


func generate_terrain():
	var noise_values = []
	for x in range(game.chunk_lenght):
		noise_values.push_back([])
		blocks.push_back([])
		for y in range(game.chunk_height):
			blocks[x].push_back([])
			for z in range(game.chunk_lenght):
				if y == 0:
					noise_values[x].push_back(game.noise.get_noise_2d(x+chunk_offset_x, z+chunk_offset_z))
				var local_noise = noise_values[x][z]
				var local_height = round(10*(local_noise+1)+5)
				var block = 0 # air
				if y == 0:
					block = 1 # bedrock
				elif y < local_height/2.0:
					block = 2 # stone
					#block = game.obtainable_blocks_indexes.pick_random()
				elif y < local_height:
					block = 3 # dirt
				elif y == local_height:
					block = 4 # grass
				blocks[x][y].push_back(block)
	draw_blocks()


func create_mesh_and_collider(x, y, z):
	place_block(Vector3(x+chunk_offset_x, y, z+chunk_offset_z), blocks[x][y][z])


func draw_blocks():
	for x in range(game.chunk_lenght):
		for y in range(game.chunk_height):
			for z in range(game.chunk_lenght):
				if check_if_any_face_visible(x, y, z, true):
					create_mesh_and_collider(x, y, z)


func check_if_any_face_visible(x_global, y, z_global, _can_call_deeper=false):
	var x = int(x_global) % game.chunk_lenght
	var z = int(z_global) % game.chunk_lenght
	# check if is air - invisible
	if blocks[x][y][z] == 0:
		return false
	
	# check if edge of chunk - visible
	if x == 0 || x == game.chunk_lenght-1 || y == 0 || y == game.chunk_height || z == 0 || z == game.chunk_lenght - 1:
		return true
	
	# check if neighbors air - visible
	if blocks[x-1][y][z]==0 || blocks[x+1][y][z]==0 || blocks[x][y-1][z]==0 || blocks[x][y+1][z]==0 || blocks[x][y][z-1]==0 || blocks[x][y][z+1]==0:
		return true
	
	# check if neighbors a visible transparent block
	#if game.transparent_blocks_indexes.has(blocks[x-1][y][z]) && (not can_call_deeper || check_if_any_face_visible(x-1, y, z)) || \
		#game.transparent_blocks_indexes.has(blocks[x+1][y][z]) && (not can_call_deeper ||check_if_any_face_visible(x+1, y, z)) || \
		#game.transparent_blocks_indexes.has(blocks[x][y-1][z]) && (not can_call_deeper ||check_if_any_face_visible(x, y-1, z)) || \
		#game.transparent_blocks_indexes.has(blocks[x][y+1][z]) && (not can_call_deeper ||check_if_any_face_visible(x, y+1, z)) || \
		#game.transparent_blocks_indexes.has(blocks[x][y][z-1]) && (not can_call_deeper ||check_if_any_face_visible(x, y, z-1)) || \
		#game.transparent_blocks_indexes.has(blocks[x][y][z+1]) && (not can_call_deeper ||check_if_any_face_visible(x, y, z+1)):
		#return true
	
	# check if any neighbor is transparent
	return game.transparent_blocks_indexes.has(blocks[x-1][y][z]) || game.transparent_blocks_indexes.has(blocks[x+1][y][z]) \
		|| game.transparent_blocks_indexes.has(blocks[x][y-1][z]) || game.transparent_blocks_indexes.has(blocks[x][y+1][z]) \
		|| game.transparent_blocks_indexes.has(blocks[x][y][z-1]) || game.transparent_blocks_indexes.has(blocks[x][y][z+1])


func check_neighboring_blocks_visibilities(x, y, z):
	return [
		x>0 && check_if_any_face_visible(x-1, y, z),
		x<game.chunk_lenght-1 && check_if_any_face_visible(x+1, y, z),
		y>0 && check_if_any_face_visible(x, y-1, z),
		y<game.chunk_height-1 && check_if_any_face_visible(x, y+1, z),
		z>0 && check_if_any_face_visible(x, y, z-1),
		z<game.chunk_lenght-1 && check_if_any_face_visible(x, y, z+1),
	]

func destroy_block_node(x, y, z):
	for child in blocks_object.get_children():
		if round(child.position.x) == round(x) and round(child.position.y) == round(y) and round(child.position.z) == round(z):
			child.queue_free()


func handle_block_appeared(block_position, block_index):
	var x = block_position.x
	var y = block_position.y
	var z = block_position.z
	var neighboring_visilities_before = check_neighboring_blocks_visibilities(x, y, z)
	blocks[x][y][z] = block_index
	var neighboring_visilities_after = check_neighboring_blocks_visibilities(x, y, z)
	x += chunk_offset_x
	z += chunk_offset_z
	for i in range(6):
		if neighboring_visilities_before[i] && !neighboring_visilities_after[i]:
			match i:
				0:
					destroy_block_node(x-1, y, z)
				1:
					destroy_block_node(x+1, y, z)
				2:
					destroy_block_node(x, y-1, z)
				3:
					destroy_block_node(x, y+1, z)
				4:
					destroy_block_node(x, y, z-1)
				5:
					destroy_block_node(x, y, z+1)


func handle_block_disappeared(block):
	var x = int(block.position.x) % game.chunk_lenght
	var y = int(block.position.y) % game.chunk_height
	var z = int(block.position.z) % game.chunk_lenght
	var neighboring_visilities_before = check_neighboring_blocks_visibilities(x, y, z)
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
	var raycast = game.block_destroyed_raycast.instantiate()
	raycast.block_destroyed_raycast = game.block_destroyed_raycast
	raycast.chunk = self
	raycast.position = block.position
	add_child(raycast)


func handle_destroy_block(block):
	var particles = game.block_broken_particles.instantiate()
	particles.material_override = block.get_node("MeshInstance3D").mesh.material
	particles.position = block.position
	particles.emitting = true
	add_child(particles)
	handle_block_disappeared(block)
	block.queue_free()


func place_block(new_block_position, index):
	if !index:
		return
	var new_block = game.blocks[index].duplicate(false)
	if new_block is RigidBody3D:
		new_block.set_script(rigidbody_script)
		new_block.chunk = self
	new_block.position = new_block_position
	new_block.name = game.blocks[index].name
	blocks_object.add_child(new_block)
	return new_block


func try_place_and_save_obtainable_block(block_position):
	var new_block_position = Vector3(int(block_position.x) % game.chunk_lenght, int(block_position.y) % game.chunk_height, int(block_position.z) % game.chunk_lenght)
	if blocks[new_block_position.x][new_block_position.y][new_block_position.z] != 0:
		return
	var block_index = game.obtainable_blocks_indexes.pick_random()
	handle_block_appeared(new_block_position, block_index) # sprawdzić
	var placed_block = place_block(new_block_position+Vector3(chunk_offset_x, 0, chunk_offset_z), block_index)
	if placed_block is RigidBody3D:
		placed_block.chunk = self
		placed_block.block_index = block_index
		if blocks[new_block_position.x][new_block_position.y-1][new_block_position.z] == 0:
			placed_block.freeze = false
			handle_block_disappeared(placed_block)


func place_commonly_spawned_block(new_block_position):
	place_block(new_block_position, game.commonly_spawned_blocks_indexes.pick_random())


func place_bedrock(new_block_position):
	place_block(new_block_position, game.name_to_index_dictionary["bedrock"])
