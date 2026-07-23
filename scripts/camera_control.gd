extends SpringArm3D

@onready var camera: Camera3D = $Camera3D
@onready var player: CharacterBody3D = self.get_parent()
var mouse_input: Vector2 = Vector2()
var mouse_sensitivity := 0.5
var camera_offset: float = self.position.y

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spring_length = camera.position.z
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	rotation_degrees.x += mouse_input.y
	rotation_degrees.y += mouse_input.x
	
	rotation_degrees.x = clampf(rotation_degrees.x,  -45, 50)
	
	mouse_input = Vector2()
	
func _physics_process(delta: float) -> void:
	# Set position of the camera to position of player + the offset to keep it a top down-ish view
	self.position = player.position + Vector3(0,camera_offset,0)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_input = -event.relative * mouse_sensitivity
		
	elif event is InputEventKey and event.keycode == KEY_ESCAPE and event.is_pressed():
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
