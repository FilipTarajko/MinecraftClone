extends RayCast3D


var block_destroyed_raycast: PackedScene
var world: Node3D


func _process(delta):
	if is_colliding() && get_collider():
		var block = get_collider()
		if block is RigidBody3D:
			block.freeze = false
			block.last_velocity = 1
		var raycast = block_destroyed_raycast.instantiate()
		raycast.block_destroyed_raycast = block_destroyed_raycast
		raycast.world = world
		raycast.position = position+Vector3(0, 1, 0)
		world.add_child(raycast)
		queue_free()
