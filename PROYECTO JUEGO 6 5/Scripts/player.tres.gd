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
var footstep_timer = 0.0
var speed = SPEED
var yaw = 0.0  # Declarar yaw
var pitch = 0.0  # Declarar pitch
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")  # Declarar gravity

@onready var camera = $Cabeza/Camera3D
@onready var footstep_sound = $Caminar  # Nodo de sonido de pasos
@onready var run_sound = $Correr  # Nodo de sonido de correr
@onready var animation = $Cabeza/Camera3D/AnimationPlayer

# Variables para la UI
var ui_control = null  # Nodo de UI para control de misiones y barra de energía
var energy_bar = null  # Nodo para la barra de energía

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# Intentar encontrar la UI en la escena actual de forma dinámica
	ui_control = get_node_or_null("/root/" + get_tree().current_scene.name + "/UI")
	
	# Si no se encuentra la UI, agregarla manualmente o lanzar advertencia
	if ui_control == null:
		print("Advertencia: No se encontró el nodo UI en la escena actual.")
	else:
		energy_bar = ui_control.get_node("EnergyBar")  # Acceder a la barra de energía

func show_instructions(text: String):
	if ui_control != null:
		ui_control.update_mission(text)  # Llamar al método para actualizar la misión

func _on_cinematic_finished():
	show_instructions("WASD para moverse")  # Mostrar instrucciones después de la cinemática

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# Control de la cámara con el ratón
		yaw -= event.relative.x * MOUSE_SENSITIVITY
		pitch -= event.relative.y * MOUSE_SENSITIVITY
		pitch = clamp(pitch, -90, 90)  # Limitar el movimiento vertical de la cámara
		rotation_degrees.y = yaw  # Rotar el cuerpo del jugador horizontalmente
		camera.rotation_degrees.x = pitch  # Rotar la cámara verticalmente

func _process(delta):
	# Controlar el sonido de los pasos
	footstep_timer -= delta
	if is_on_floor() and speed == SPEED and velocity.length() > 0 and footstep_timer <= 0:
		footstep_sound.volume_db = -10
		footstep_sound.play()
		footstep_timer = 1  # Ajusta el intervalo de tiempo entre pasos

func _physics_process(delta):
	# No hacer nada si no se puede mover o si hay una cinemática activa
	if not movable or cinematic_active:
		return  # Salir de la función si no está permitido moverse

	# Aplicar gravedad si no está en el suelo
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Obtener el vector de movimiento a partir de la entrada del jugador
	var input_dir = Input.get_vector("atras", "avanzar", "izquierda", "derecha")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Movimiento
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

		# Reproducir animaciones
		if speed == RUN_SPEED:
			animation.play("CamaraCorrer")
		else:
			animation.play("animacion")  # Reproducir animación de caminar

		# Mostrar instrucciones en la UI (opcional)
		if ui_control != null:
			ui_control.update_mission("")

		# Control del sprint
		if Input.is_action_just_pressed("Correr"):
			speed = RUN_SPEED
			if not run_sound.playing:
				run_sound.play()
		if Input.is_action_just_released("Correr"):
			speed = SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		run_sound.stop()
		footstep_sound.volume_db -= 40 * delta  # Reduce el volumen de forma gradual
		if footstep_sound.volume_db <= -80:  # Considerar -80dB como "silencio"
			footstep_sound.stop()

		# Detener la animación cuando el jugador no se mueve
		animation.stop()

	move_and_slide()
