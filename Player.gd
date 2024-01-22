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
@export var block_space_checker: Area3D
var entities_in_checked_area: int


var is_in_third_person = true
@onready var default_camera_offset = camera.position
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var raycasted_object_name = ""
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


func update_raycasted_object_name(pos_unrounded):
	var pos = round(pos_unrounded)
	var x = pos.x
	var y = pos.y
	var z = pos.z
	if game.block_types[world.blocks[x][y][z]]:
		raycasted_object_name = game.block_types[world.blocks[x][y][z]].name

func handle_raycast_interactions():
	if !camera_raycast.is_colliding() || !camera_raycast.get_collider():
		block_highlighter.hide()
		raycasted_object_name = ""
		return
	update_raycasted_object_name(camera_raycast.get_collider().position)
	block_highlighter.show()
	block_highlighter.position = camera_raycast.get_collider().position
	var obj = camera_raycast.get_collider()
	if Input.is_action_just_pressed("hit"):
		world.handle_destroy_block(obj)
	var collision_normal = camera_raycast.get_collision_normal()
	var collision_point = camera_raycast.get_collision_point()
	var new_block_position = (collision_point+collision_normal/2).round()
	block_space_checker.position = new_block_position
	if Input.is_action_just_pressed("use") && entities_in_checked_area == 0:
		world.try_place_and_save_obtainable_block(new_block_position)


func _on_block_space_checker_body_entered(_body):
	entities_in_checked_area += 1


func _on_block_space_checker_body_exited(_body):
	entities_in_checked_area -= 1
