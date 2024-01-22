extends RigidBody3D

var last_velocity = 1


var chunk
var block_index: int


func is_nearly_zero(num):
	return num < 0.001 && num > -0.001 


func _physics_process(_delta):
	if not freeze:
		if is_nearly_zero(last_velocity) && is_nearly_zero(linear_velocity.y):
			position.y = round(position.y)
			freeze = true
			var chunk_pos = Vector3(int(position.x) % chunk.game.chunk_lenght, int(position.y) % chunk.game.chunk_height, int(position.z) % chunk.game.chunk_lenght)
			chunk.handle_block_appeared(chunk_pos, block_index)
		last_velocity = linear_velocity.y
