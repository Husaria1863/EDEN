extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var turn_speed: float = 10.0

@export var mouse_sensitivity: float = 0.003
@export var min_pitch_degrees: float = -30.0
@export var max_pitch_degrees: float = 35.0

@export var camera_distance: float = 4.0
@export var camera_min_distance: float = 0.75
@export var camera_collision_margin: float = 0.2
@export var camera_smooth_speed: float = 18.0

@export var idle_animation: String = "idle/mixamo_com"
@export var walk_animation: String = "walk_forward/mixamo_com"
@export var jump_animation: String = "jump/mixamo_com"

@export var model_yaw_offset_degrees: float = 180.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var animation_player: AnimationPlayer
var model_node: Node3D
var camera_yaw: Node3D
var camera_pitch: Node3D
var spring_arm: SpringArm3D
var camera_collision: ShapeCast3D

var current_animation: String = ""
var pitch: float = 0.0


func _ready() -> void:
	model_node = get_node_or_null("Model")
	camera_yaw = get_node_or_null("CameraYaw")
	camera_pitch = get_node_or_null("CameraYaw/CameraPitch")
	spring_arm = get_node_or_null("CameraYaw/CameraPitch/SpringArm3D")
	camera_collision = get_node_or_null("CameraYaw/CameraPitch/CameraCollision")

	if model_node == null:
		push_error("No Model node found under Player.")
		return

	if camera_yaw == null:
		push_error("No CameraYaw node found under Player.")
		return

	if camera_pitch == null:
		push_error("No CameraPitch node found under CameraYaw.")
		return

	if spring_arm == null:
		push_error("No SpringArm3D found under CameraPitch.")
		return

	if camera_collision == null:
		push_error("No CameraCollision ShapeCast3D found under CameraPitch.")
		return

	animation_player = model_node.find_child("AnimationPlayer", true, false) as AnimationPlayer

	if animation_player == null:
		push_error("No AnimationPlayer found under Model.")
		return

	# SpringArm still controls distance, but collision is handled manually.
	spring_arm.collision_mask = 0
	spring_arm.spring_length = camera_distance

	camera_collision.target_position = Vector3(0.0, 0.0, camera_distance)
	camera_collision.enabled = true
	camera_collision.add_exception(self)

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	print("Available animations: ", animation_player.get_animation_list())

	play_animation(idle_animation)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_yaw.rotate_y(-event.relative.x * mouse_sensitivity)

		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(
			pitch,
			deg_to_rad(min_pitch_degrees),
			deg_to_rad(max_pitch_degrees)
		)

		camera_pitch.rotation.x = pitch

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_jump()
	handle_movement(delta)
	move_and_slide()
	update_animation()
	update_camera_collision(delta)


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta


func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		play_animation(jump_animation)


func handle_movement(delta: float) -> void:
	var input_dir := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_back"
	)

	var direction := Vector3.ZERO

	if camera_yaw:
		var camera_basis := camera_yaw.global_transform.basis
		var camera_right := camera_basis.x
		var camera_forward := camera_basis.z

		direction = camera_right * input_dir.x + camera_forward * input_dir.y
		direction.y = 0.0
		direction = direction.normalized()

	if direction.length() > 0.0:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

		if model_node:
			var target_angle := atan2(-direction.x, -direction.z) + deg_to_rad(model_yaw_offset_degrees)
			model_node.rotation.y = lerp_angle(model_node.rotation.y, target_angle, turn_speed * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)
		velocity.z = move_toward(velocity.z, 0.0, speed)


func update_camera_collision(delta: float) -> void:
	if camera_collision == null or spring_arm == null:
		return

	camera_collision.target_position = Vector3(0.0, 0.0, camera_distance)
	camera_collision.force_shapecast_update()

	var target_length := camera_distance

	if camera_collision.is_colliding():
		var safe_fraction := camera_collision.get_closest_collision_safe_fraction()
		target_length = camera_distance * safe_fraction
		target_length -= camera_collision_margin
		target_length = clamp(target_length, camera_min_distance, camera_distance)

	var smoothing := 1.0 - exp(-camera_smooth_speed * delta)
	spring_arm.spring_length = lerp(spring_arm.spring_length, target_length, smoothing)


func update_animation() -> void:
	if animation_player == null:
		return

	var horizontal_speed := Vector2(velocity.x, velocity.z).length()

	if not is_on_floor():
		play_animation(jump_animation)
	elif horizontal_speed > 0.1:
		play_animation(walk_animation)
	else:
		play_animation(idle_animation)


func play_animation(animation_name: String) -> void:
	if animation_player == null:
		return

	if current_animation == animation_name:
		return

	if animation_player.has_animation(animation_name):
		animation_player.play(animation_name, 0.15)
		current_animation = animation_name
	else:
		print("Missing animation: ", animation_name)
