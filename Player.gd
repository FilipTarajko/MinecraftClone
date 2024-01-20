extends CharacterBody3D

const X_SENSITIVITY = 0.01
const Y_SENSITIVITY = 0.01
const SPEED = 6.0
const JUMP_VELOCITY = 5.0

@onready var camera_stick = get_node("CameraStick")
@onready var camera = get_node("CameraStick/Camera3D")
@onready var camera_raycast = get_node("CameraStick/Camera3D/RayCast3D")
@onready var world = get_node("../World")
@onready var block_highlighter = get_node("../BlockHighlighter")
@onready var textures = [preload("res://block_images/grass.png"), preload("res://block_images/dirt.png")]

var is_in_third_person = true
@onready var default_camera_offset = camera.position
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var block_to_place = preload("res://block.tscn")


func _physics_process(delta):
	handle_movement(delta)

func _process(delta):
	handle_third_person_toggle()
	handle_raycast_interactions()


func handle_movement(delta):
	# gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	# jumping
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
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
	if (Input.is_action_just_pressed("toggle_third_person_mode")):
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
		obj.queue_free()
	if Input.is_action_just_pressed("use"):
		var new_block = block_to_place.instantiate()
		var collision_normal = camera_raycast.get_collision_normal()
		var collision_point = camera_raycast.get_collision_point()
		new_block.get_child(1).mesh.material.albedo_texture = textures[randi()%2]
		new_block.position = (collision_point+collision_normal/2).round() 
		world.add_child(new_block)
