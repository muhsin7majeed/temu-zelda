extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const TURN_SPEED = 15

@onready var camera: Camera3D = $SpringArm3D/Camera3D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * 1.5

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get input vector
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	# Calculate direction relative to camera transform
	var direction := camera.global_basis * Vector3(input_dir.x, 0, input_dir.y)
	
	# Flatten vector to horizontal plane (keep X and Z, eliminate vertical tilt)
	direction.y = 0
	direction = direction.normalized()
	
	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		turn_mesh(direction, delta)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	move_and_slide()
	
func turn_mesh(direction: Vector3, delta: float) -> void:
	var yaw = atan2(-direction.x, -direction.z)

	# Lerping to enable smooth turning
	self.rotation.y = lerp_angle(rotation.y, yaw, TURN_SPEED * delta)
