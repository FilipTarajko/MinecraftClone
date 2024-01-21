extends RigidBody3D

var last_velocity = 1
var block_below: PhysicsBody3D
var raycast

func handle_block_below():
	raycast = RayCast3D.new()
	raycast.enabled = true
	raycast.target_position = Vector3(0, -0.51, 0)
	add_child(raycast)

func _physics_process(_delta):
	if not block_below:
		freeze = false
	if not freeze:
		if last_velocity == 0 && linear_velocity.y == 0:
			handle_block_below()
			position.y = round(position.y)
		last_velocity = linear_velocity.y
		if !!raycast && raycast.is_colliding() && raycast.get_collider():
			block_below = raycast.get_collider()
			raycast.enabled = false
			raycast.queue_free()
			freeze = true
			position.y = round(position.y)
