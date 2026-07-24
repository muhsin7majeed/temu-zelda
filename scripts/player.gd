extends CharacterBody3D

const WALK_SPEED = 5
const JUMP_VELOCITY = 4.5
const TURN_SPEED = 0.25

@onready var camera: Camera3D = $SpringArm3D/Camera3D
@onready var player_animation: AnimationPlayer = $Mesh/AnimationPlayer
@onready var player_animation_tree: AnimationTree = $AnimationTree

func _physics_process(delta: float) -> void:
	# Get input vector
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	# Calculate direction relative to camera transform
	var direction := camera.global_basis * Vector3(input_dir.x, 0, input_dir.y)
	
	# Flatten vector to horizontal plane (keep X and Z, eliminate vertical tilt)
	direction.y = 0
	direction = direction.normalized()
	
	if direction != Vector3.ZERO:
		velocity.x = direction.x * WALK_SPEED
		velocity.z = direction.z * WALK_SPEED
		
		turn_mesh(direction)
	else:
		velocity.x = move_toward(velocity.x, 0, WALK_SPEED)
		velocity.z = move_toward(velocity.z, 0, WALK_SPEED)
		
	move_and_slide()
	
	var current_speed = velocity.length()
	
	# Anything above 3, consider it as run!
	if current_speed > 3.0:
		player_animation_tree.set("parameters/movement/transition_request", "run")
	elif current_speed > 0.0:
		player_animation_tree.set("parameters/movement/transition_request", "walk")
		
		var walk_speed = lerp(.5, 1.5, current_speed /3)
		player_animation_tree.set("parameters/WalkSpeed/scale", walk_speed)
	else:
		player_animation_tree.set("parameters/movement/transition_request", "idle")
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
		if velocity.y != 0:
			print("ABOUT TO JUMP")
			player_animation_tree.set("parameters/movement/transition_request", "jump")

		# Fix the landing animation
		#elif velocity.y < -4.5:
			#print("ABOUT TO LAND")
			#player_animation_tree.set("parameters/movement/transition_request", "jump_land")
		
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
func turn_mesh(direction: Vector3) -> void:
	var yaw = atan2(-direction.x, -direction.z)

	# Lerping to enable smooth turning
	self.rotation.y = lerp_angle(rotation.y, yaw, TURN_SPEED)
