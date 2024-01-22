extends RigidBody3D

var last_velocity = 1


var world
var block_index: int


func is_nearly_zero(num):
	return num < 0.001 && num > -0.001 


func _physics_process(_delta):
	if not freeze:
		print(linear_velocity.y)
		if is_nearly_zero(last_velocity) && is_nearly_zero(linear_velocity.y):
			position.y = round(position.y)
			freeze = true
			world.handle_block_appeared(position, block_index)
		last_velocity = linear_velocity.y
