extends CharacterBody3D

const X_SENSITIVITY = 0.0001
const Y_SENSITIVITY = 0.0001
const SPEED = 6.0
const JUMP_VELOCITY = 5.0

var camera_stick
var camera
var camera_raycast
var is_in_third_person = true
var default_camera_offset
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	camera_stick = get_node("CameraStick")
	camera = get_node("CameraStick/Camera3D")
	camera_raycast = get_node("CameraStick/Camera3D/RayCast3D")
	default_camera_offset = camera.position


func _physics_process(delta):
	handle_movement(delta)
	handle_camera(delta)
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


func handle_camera(delta):
	# camera rotation
	if (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		var mouse_velocity = Input.get_last_mouse_velocity()
		camera_stick.rotate_y(-mouse_velocity.x*X_SENSITIVITY)
		camera_stick.rotate_object_local(Vector3.RIGHT, -mouse_velocity.y*Y_SENSITIVITY)
	if (Input.is_action_just_pressed("toggle_third_person_mode")):
		if is_in_third_person:
			camera.position = Vector3(0, 0, 0)
			is_in_third_person = false
		else:
			camera.position = default_camera_offset
			is_in_third_person = true


func handle_raycast_interactions():
	if camera_raycast.is_colliding():
		var obj = camera_raycast.get_collider()
		if Input.is_action_just_pressed("hit"):
			obj.queue_free()
