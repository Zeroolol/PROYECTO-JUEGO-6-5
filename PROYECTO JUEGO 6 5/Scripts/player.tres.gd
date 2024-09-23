extends CharacterBody3D

const SPEED = 4.0
const RUN_SPEED = 6.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.2
const MAX_ENERGY = 100
const RUN_ENERGY_COST = 25.0
const ENERGY_RECOVERY_RATE = 15.0

var movable = true  # Controla si el jugador puede moverse
var cinematic_active = false  # Variable para controlar si una cinemática está activa
var current_energy = MAX_ENERGY
var running = false
var footstep_timer = 0.0
var speed = SPEED

@onready var camera = $Cabeza/Camera3D
@onready var energy_bar = null  # Nodo de UI para la barra de energía
@onready var footstep_sound = $Caminar  # Nodo de sonido de pasos
@onready var run_sound = $Correr  # Nodo de sonido de correr
@onready var animation = $Cabeza/Camera3D/AnimationPlayer
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var yaw = 0.0  
var pitch = 0.0  

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	energy_bar = get_node("/root/" + get_tree().current_scene.name + "/UI/EnergyBar")  # Acceder al nodo root para encontrar la UI

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * MOUSE_SENSITIVITY
		pitch -= event.relative.y * MOUSE_SENSITIVITY
		pitch = clamp(pitch, -90, 90)
		rotation_degrees.y = yaw
		camera.rotation_degrees.x = pitch

func _process(delta):
	if speed == RUN_SPEED:
		if footstep_sound.playing:
			footstep_sound.stop()
		energy_bar.value -= RUN_ENERGY_COST * delta
		if energy_bar.value <= energy_bar.min_value or (velocity.x == 0 and velocity.z == 0):
			speed = SPEED
			if run_sound.playing:
				run_sound.stop()
	elif speed != RUN_SPEED:
		if energy_bar.value < energy_bar.max_value:
			energy_bar.value += ENERGY_RECOVERY_RATE * delta

	# Controlar el sonido de los pasos
	footstep_timer -= delta
	if is_on_floor() and speed == SPEED and velocity.length() > 0 and footstep_timer <= 0:
		footstep_sound.play()
		footstep_timer = 0.5  # Ajusta el intervalo de tiempo entre pasos

func _physics_process(delta):
	# No hacer nada si no se puede mover o si hay una cinemática activa
	if not movable or cinematic_active:
		return  # Salir de la función si no está permitido moverse

	if not is_on_floor():
		velocity.y -= gravity * delta

	# Control de movimiento si el jugador es "movable"
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("atras", "avanzar", "izquierda", "derecha")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Movimiento
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		animation.play("animacion")

		if Input.is_action_just_pressed("Correr"):
			speed = RUN_SPEED
			animation.play("CamaraCorrer")
			if not run_sound.playing:
				run_sound.play()
		if Input.is_action_just_released("Correr"):
			speed = SPEED
			animation.play("CamaraCorrer")
			if run_sound.playing:
				run_sound.stop()
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		run_sound.stop()
		footstep_sound.stop()
		
	move_and_slide()
