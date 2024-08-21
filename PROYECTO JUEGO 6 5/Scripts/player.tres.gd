extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Store a reference to the camera node
@onready var camera = $Cabeza/Camera3D

# Variables for camera rotation
var yaw = 0.0  # Horizontal rotation (left/right)
var pitch = 0.0  # Vertical rotation (up/down)

func _ready():
	# Capture the mouse to control the camera.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# Update the yaw and pitch based on mouse movement
		yaw -= event.relative.x * MOUSE_SENSITIVITY
		pitch -= event.relative.y * MOUSE_SENSITIVITY

		# Clamp the pitch to prevent the camera from flipping vertically
		pitch = clamp(pitch, -90, 90)

		# Apply the rotation to the camera and the character body
		rotation_degrees.y = yaw
		camera.rotation_degrees.x = pitch

func _physics_process(delta):
	# Add gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle movement.
	var input_dir = Input.get_vector("izquierda", "derecha", "avanzar", "atras")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
