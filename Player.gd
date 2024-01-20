extends CharacterBody3D

const X_SENSITIVITY = 0.0001
const Y_SENSITIVITY = 0.0001

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var camera_stick

func _ready():
	camera_stick = get_node("CameraStick")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	if Input.is_key_pressed(KEY_R):
		get_tree().reload_current_scene()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	input_dir = input_dir.rotated(-camera_stick.rotation.y)
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	var mouse_velocity = Input.get_last_mouse_velocity()
	camera_stick.rotate_y(-mouse_velocity.x*X_SENSITIVITY)
	camera_stick.rotate_object_local(Vector3.RIGHT, -mouse_velocity.y*Y_SENSITIVITY)


	move_and_slide()
