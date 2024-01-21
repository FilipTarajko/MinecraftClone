extends RigidBody3D

var last_velocity = 1


func _physics_process(_delta):
	if not freeze:
		if last_velocity == 0 && linear_velocity.y == 0:
			position.y = round(position.y)
			freeze = true
		last_velocity = linear_velocity.y
