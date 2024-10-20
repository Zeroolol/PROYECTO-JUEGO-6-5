extends CharacterBody3D

const SPEED = 4.0
const RUN_SPEED = 6.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.2
const MAX_ENERGY = 100
const RUN_ENERGY_COST = 25.0
const ENERGY_RECOVERY_RATE = 15.0

var movable = true
var cinematic_active = false
var current_energy = MAX_ENERGY
var footstep_timer = 0.0
var speed = SPEED
var yaw = 0.0
var pitch = 0.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var is_hidden = false  # Variable para controlar si el jugador está oculto
@onready var armario = null  # Variable para referenciar el armario

@onready var camera = $Cabeza/Camera3D
@onready var footstep_sound = $Caminar
@onready var run_sound = $Correr
@onready var animation = $Cabeza/Camera3D/AnimationPlayer
@onready var llave_modelo = $Llaves  # Nodo del modelo de la llave en la cámara

@export var walk_speed: float = 4.0

var ui_control = null
var energy_bar = null
var inventario = []  # Lista para almacenar los ítems recogidos
var llave_en_inventario = false  # Indica si la llave está en el inventario
var item_seleccionado = ""  # Variable para almacenar el ítem actualmente seleccionado

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ui_control = get_node_or_null("/root/" + get_tree().current_scene.name + "/UI")
	
	if ui_control == null:
		print("Advertencia: No se encontró el nodo UI en la escena actual.")
	else:
		energy_bar = ui_control.get_node("EnergyBar")
		energy_bar.visible = false 

	llave_modelo.visible = false  # La llave no será visible hasta que el jugador la recoja

# Función para recoger la llave
func recoger_llave():
	inventario.append("LlaveTest")  # Agrega la llave al inventario
	llave_en_inventario = true
	llave_modelo.visible = true  # Muestra el modelo de la llave
	print("Llave recogida y agregada al inventario")

# Función para seleccionar un ítem del inventario
func seleccionar_item(item: String):
	item_seleccionado = item  # Actualiza el ítem seleccionado
	if item == "LlaveTest":
		llave_en_inventario = true
		mostrar_llave()
	else:
		llave_en_inventario = false
		ocultar_llave()

# Muestra la llave en la mano del jugador
func mostrar_llave():
	if llave_en_inventario:
		llave_modelo.visible = true  # Muestra la llave
	else:
		llave_modelo.visible = false  # Oculta la llave si no está seleccionada

# Oculta la llave
func ocultar_llave():
	llave_modelo.visible = false

func show_instructions(text: String):
	if ui_control != null:
		ui_control.update_mission(text)

func get_walk_speed() -> float:
	return walk_speed

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * MOUSE_SENSITIVITY
		pitch -= event.relative.y * MOUSE_SENSITIVITY
		pitch = clamp(pitch, -90, 90)
		rotation_degrees.y = yaw
		camera.rotation_degrees.x = pitch

func hide_in_armario():
	is_hidden = true
	$MeshInstance.visible = false  # Ocultar visualmente al jugador
	velocity = Vector3.ZERO  # Detener el movimiento
	print("Jugador está oculto en el armario")

func exit_armario():
	is_hidden = false
	$MeshInstance.visible = true  # Hacer visible al jugador de nuevo
	print("Jugador salió del armario")

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
	
	if energy_bar.value < energy_bar.max_value:
		energy_bar.visible = true
	else:
		energy_bar.visible = false

	# Controlar el sonido de los pasos
	footstep_timer -= delta
	if is_on_floor() and velocity.length() > 0.1 and footstep_timer <= 0:
		if not footstep_sound.playing:
			footstep_sound.volume_db = -10
			footstep_sound.play()
		footstep_timer = 0.5
	elif velocity.length() <= 0.1:
		if footstep_sound.playing:
			footstep_sound.volume_db -= 10 * delta
			if footstep_sound.volume_db <= -80:
				footstep_sound.stop()

	if not movable or cinematic_active:
		return
	
	if ui_control != null:
		ui_control.update_mission("")

	if not is_on_floor():
		velocity.y -= gravity * delta
	
	var input_dir = Input.get_vector("atras", "avanzar", "izquierda", "derecha")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Movimiento
	if direction.length() > 0:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

		if speed == SPEED:
			if not animation.is_playing() or animation.current_animation != "animacion":
				animation.play("animacion")  # Asegúrate de que la animación de caminar se reproduzca
		elif speed == RUN_SPEED:
			if not animation.is_playing() or animation.current_animation != "CamaraCorrer":
				animation.play("CamaraCorrer")  # Asegúrate de que la animación de correr se reproduzca

		if Input.is_action_just_pressed("Correr"):
			speed = RUN_SPEED
			if not run_sound.playing:
				run_sound.play()
		if Input.is_action_just_released("Correr"):
			speed = SPEED
			if run_sound.playing:
				run_sound.stop()
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
		if animation.is_playing():
			animation.stop()  # Detener la animación si el personaje no se está moviendo
		if run_sound.playing:
			run_sound.stop()
		if footstep_sound.playing:
			footstep_sound.stop()

	# Verificar si el jugador quiere entrar o salir del armario
	if Input.is_action_just_pressed("Interact"):  # Asume que "interact" es la acción para interactuar
		if armario and is_hidden == false:  # Si no está oculto
			hide_in_armario()  # Ocultarse en el armario
		elif is_hidden:  # Si está oculto
			exit_armario()  # Salir del armario

	move_and_slide()
	
	# Asumiendo que tienes un inventario visual y el jugador selecciona la llave
func _input(event):
	if event.is_action_pressed("Aceptar"):  # "Aceptar" es la acción de interacción
		seleccionar_item("LlaveTest")
