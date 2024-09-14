extends CharacterBody3D

const SPEED = 4.0
const RUN_SPEED = 6.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.2
const MAX_ENERGY = 100
const RUN_ENERGY_COST = 25.0
const ENERGY_RECOVERY_RATE = 15.0

var movable = false
var current_energy = MAX_ENERGY
var running = false
var footstep_timer = 0.0

@onready var camera = $Cabeza/Camera3D
@onready var energy_bar = null  # Nodo de UI para la barra de energía
@onready var footstep_sound = $Caminar  # Nodo de sonido de pasos
@onready var run_sound = $Correr  # Nodo de sonido de correr

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var yaw = 0.0  
var pitch = 0.0  

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# Asegúrate de que el nodo UI esté cargado correctamente
	var ui_scene = get_tree().root.get_node("UI")  # Acceder al nodo root para encontrar la UI
	if ui_scene:
		energy_bar = ui_scene.get_node("EnergyBar")
		if energy_bar:
			energy_bar.max_value = MAX_ENERGY  # Asegúrate de que el valor máximo de la barra de energía sea correcto
		else:
			print("Error: Nodo 'EnergyBar' no encontrado en la escena UI")
	else:
		print("Error: UI no encontrada en el árbol de nodos")

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * MOUSE_SENSITIVITY
		pitch -= event.relative.y * MOUSE_SENSITIVITY
		pitch = clamp(pitch, -90, 90)
		rotation_degrees.y = yaw
		camera.rotation_degrees.x = pitch

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if movable:
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		var input_dir = Input.get_vector("atras", "avanzar", "izquierda", "derecha")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		var speed = SPEED

		if Input.is_action_pressed("avanzar") and Input.is_action_pressed("Correr") and current_energy > 0 and is_on_floor():
			running = true
			if not run_sound.playing:
				run_sound.play()  # Reproduce el sonido de correr si no se está reproduciendo
			if footstep_sound.playing:
				footstep_sound.stop()  # Detiene el sonido de pasos si se está reproduciendo
		else:
			running = false
			if run_sound.playing:
				run_sound.stop()  # Detiene el sonido de correr si está reproduciéndose
			if not footstep_sound.playing:
				footstep_timer -= delta
				if footstep_timer <= 0:
					if direction:
						footstep_sound.play()  # Reproduce el sonido de pasos si no está reproduciéndose
					footstep_timer = 0.5  # Intervalo entre pasos

		if running:
			speed = RUN_SPEED
			current_energy -= RUN_ENERGY_COST * delta
			if current_energy <= 0:
				running = false
		else:
			current_energy = min(current_energy + ENERGY_RECOVERY_RATE * delta, MAX_ENERGY)

		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
			if footstep_sound.playing:
				footstep_sound.stop()  # Detiene el sonido de pasos si no hay movimiento

		move_and_slide()

		if energy_bar:
			energy_bar.value = current_energy
