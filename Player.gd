extends CharacterBody3D

const X_SENSITIVITY = 0.01
const Y_SENSITIVITY = 0.01
const SPEED = 6.0
const JUMP_VELOCITY = 5.0

@export var camera_stick: Node3D
@export var camera: Camera3D
@export var camera_raycast: RayCast3D
@export var world: Node3D
@export var game: Node3D
@export var block_highlighter: Node3D
@export var block_broken_particles: PackedScene
@export var block_destroyed_raycast: PackedScene

var is_in_third_person = true
@onready var default_camera_offset = camera.position
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var is_game_just_started = true


func _physics_process(delta):
	handle_movement(delta)

func _process(_delta):
	handle_third_person_toggle()
	handle_raycast_interactions()


func handle_movement(delta):
	# gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	# jumping
	if Input.is_action_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# movement
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	input_dir = input_dir.rotated(-camera_stick.rotation.y)
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()


func _input(event):
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# pan
		camera_stick.rotate_y(-event.relative.x*X_SENSITIVITY)
		# tilt
		var to_tilt = -event.relative.y*Y_SENSITIVITY
		if to_tilt > 0 && to_tilt > PI/2-camera_stick.rotation.x-to_tilt:
			to_tilt = PI/2-camera_stick.rotation.x
		elif to_tilt < 0 && to_tilt < -PI/2-camera_stick.rotation.x-to_tilt:
			to_tilt = -PI/2-camera_stick.rotation.x
		else:
			camera_stick.rotate_object_local(Vector3.RIGHT, to_tilt)


func handle_third_person_toggle():
	if (Input.is_action_just_pressed("toggle_third_person_mode")) || is_game_just_started:
		is_game_just_started = false
		if is_in_third_person:
			camera.position = Vector3(0, 0, 0)
			is_in_third_person = false
		else:
			camera.position = default_camera_offset
			is_in_third_person = true


func handle_raycast_interactions():
	if !camera_raycast.is_colliding() || !camera_raycast.get_collider():
		block_highlighter.hide()
		return
	block_highlighter.show()
	block_highlighter.position = camera_raycast.get_collider().position
	var obj = camera_raycast.get_collider()
	if Input.is_action_just_pressed("hit"):
		handle_destroy_block(obj)
	if Input.is_action_just_pressed("use"):
		var collision_normal = camera_raycast.get_collision_normal()
		var collision_point = camera_raycast.get_collision_point()
		var new_block_position = (collision_point+collision_normal/2).round() 
		world.place_obtainable_block(new_block_position)


func handle_destroy_block(block):
	var particles = block_broken_particles.instantiate()
	particles.material_override = block.get_node("MeshInstance3D").mesh.material
	particles.position = block.position
	particles.emitting = true
	world.add_child(particles)
	var raycast = block_destroyed_raycast.instantiate()
	raycast.block_destroyed_raycast = block_destroyed_raycast
	raycast.world = world
	raycast.position = block.position
	world.add_child(raycast)
	block.queue_free()
