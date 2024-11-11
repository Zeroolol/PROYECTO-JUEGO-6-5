extends CharacterBody3D

# Constantes de configuración del jugador
const PLAYER_SPEED = 4.0
const PLAYER_RUN_SPEED = 6.0
const PLAYER_JUMP_VELOCITY = 4.5
const PLAYER_MOUSE_SENSITIVITY = 0.2
const PLAYER_MAX_ENERGY = 100
const PLAYER_RUN_ENERGY_COST = 25.0
const PLAYER_ENERGY_RECOVERY_RATE = 15.0

# Variables del jugador
var movable = true
var is_cinematic_active = false
var current_energy = PLAYER_MAX_ENERGY
var step_timer = 0.0
var player_speed = PLAYER_SPEED
var camera_yaw = 0.0
var camera_pitch = 0.0
var player_gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var is_player_hidden = false
@onready var wardrobe = null

# Referencias a la cámara y sonido
@onready var player_camera = $Cabeza/Camera3D
@onready var sound_footsteps = $Caminar
@onready var sound_run = $Correr
@onready var anim_player = $Cabeza/Camera3D/AnimationPlayer

@export var player_walk_speed: float = 4.0

# UI y elementos del inventario
var ui_control = null
var energy_bar = null
var inventario = []  # Inventario del jugador
var selected_item = ""  # Ítem seleccionado
var keys : Array = []  # Llaves que tiene el jugador

# Diccionario para almacenar referencias a los nodos 3D de los ítems
@onready var items_visibles = {
	"LlaveTest": $Cabeza/Camera3D/Llaves,  # Nodo del modelo de la llave
	"Linterna": $Cabeza/Camera3D/Linterna,
	"Palanca": $Cabeza/Camera3D/Crowbar,
	"Llaves Aula": $Cabeza/Camera3D/LlaveAulas,
	"Llaves Labs": $Cabeza/Camera3D/LlaveLabs,
	"LlaveLab0": $Cabeza/Camera3D/LlaveLab0
}

# Configuración del RayCast para interacción
@onready var raycast = $RayCast3D  # Asegúrate de tener un RayCast3D en tu escena

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ui_control = get_node_or_null("/root/" + get_tree().current_scene.name + "/UI")

	if ui_control == null:
		print("Advertencia: No se encontró el nodo UI en la escena actual.")
	else:
		energy_bar = ui_control.get_node("EnergyBar")
		energy_bar.visible = false 

	# Ocultar todos los ítems al iniciar
	ocultar_todos_los_items()

# Función para recoger un ítem
func recoger_item(item_name: String):
	if item_name not in inventario:
		inventario.append(item_name)
		print(item_name, " recogido y agregado al inventario")

# Función para seleccionar un ítem del inventario
func seleccionar_item(item: String):
	selected_item = item  # Actualiza el ítem seleccionado
	mostrar_item_seleccionado(item)

# Muestra el ítem seleccionado en la mano del jugador
func mostrar_item_seleccionado(item: String):
	for item_name in items_visibles.keys():
		var item_node = items_visibles[item_name]  # Obtener el nodo del diccionario
		if item_node != null:  # Verificar que no sea null
			if item_name == item:
				item_node.visible = true  # Muestra el ítem seleccionado
			else:
				item_node.visible = false  # Oculta los otros ítems
		else:
			print("Advertencia: El nodo ", item_name, " no se encontró.")


# Oculta todos los ítems
func ocultar_todos_los_items():
	for item_name in items_visibles.keys():
		items_visibles[item_name].visible = false

# Función para verificar si un ítem está seleccionado
func is_item_selected(item_name: String) -> bool:
	return selected_item == item_name  # Devuelve true si el ítem está seleccionado

# Movimiento y cámara
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		camera_yaw -= event.relative.x * PLAYER_MOUSE_SENSITIVITY
		camera_pitch -= event.relative.y * PLAYER_MOUSE_SENSITIVITY
		camera_pitch = clamp(camera_pitch, -90, 90)
		rotation_degrees.y = camera_yaw
		player_camera.rotation_degrees.x = camera_pitch

# Función de actualización del jugador
func _process(delta):
	if movable and not is_cinematic_active:
		# Control de energía y velocidad al correr
		if player_speed == PLAYER_RUN_SPEED:
			if sound_footsteps.playing:
				sound_footsteps.stop()
			energy_bar.value -= PLAYER_RUN_ENERGY_COST * delta
			if energy_bar.value <= energy_bar.min_value or (velocity.x == 0 and velocity.z == 0):
				player_speed = PLAYER_SPEED
				if sound_run.playing:
					sound_run.stop()
		else:
			if energy_bar.value < energy_bar.max_value:
				energy_bar.value += PLAYER_ENERGY_RECOVERY_RATE * delta
		
		# Control del sonido de pasos
		step_timer -= delta
		if is_on_floor() and velocity.length() > 0.1 and step_timer <= 0:
			if not sound_footsteps.is_playing():
				sound_footsteps.volume_db = -10
				sound_footsteps.play()
			step_timer = 0.5
		elif velocity.length() <= 0.1:
			if sound_footsteps.is_playing():
				sound_footsteps.stop()

		# Movimiento y animación
		var input_dir = Input.get_vector("atras", "avanzar", "izquierda", "derecha")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction.length() > 0:
			velocity.x = direction.x * player_speed
			velocity.z = direction.z * player_speed

			if player_speed == PLAYER_SPEED:
				if not anim_player.is_playing() or anim_player.current_animation != "animacion":
					anim_player.play("animacion")
			elif player_speed == PLAYER_RUN_SPEED:
				if not anim_player.is_playing() or anim_player.current_animation != "CamaraCorrer":
					anim_player.play("CamaraCorrer")
		else:
			velocity.x = move_toward(velocity.x, 0, player_speed)
			velocity.z = move_toward(velocity.z, 0, player_speed)
			if anim_player.is_playing():
				anim_player.stop()

		# Control de correr
		if Input.is_action_just_pressed("Correr"):
			player_speed = PLAYER_RUN_SPEED
			if not sound_run.is_playing():
				sound_run.play()

		if Input.is_action_just_released("Correr"):
			player_speed = PLAYER_SPEED
			if sound_run.is_playing():
				sound_run.stop()

	move_and_slide()

	# Interacción con puertas usando raycast
	if Input.is_action_just_pressed("interactuar"):  # Tecla de interacción
		var resultado = raycast.get_collider()  # Obtener el objeto que el RayCast detecta
		if resultado and resultado.is_in_group("puertas"):  # Si es una puerta
			resultado.interact(self)  # Llamar a la función interact de la puerta

# Método para recoger una llave
func collect_key(key_name: String):
	keys.append(key_name)  # Agregar llave al inventario

# Función para verificar si el jugador tiene una llave
func has_key(key_name: String) -> bool:
	return keys.has(key_name)  # Devolver true si tiene la llave, false si no

# Función para verificar si la llave está seleccionada
func is_key_selected() -> bool:
	return selected_item == "LlaveTest"  # Cambiar "LlaveTest" por el nombre de la llave correspondiente
