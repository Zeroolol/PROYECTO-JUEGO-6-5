extends Node3D 

@onready var player = get_node("/root/" + get_tree().current_scene.name + "/Player/CharacterBody3D")
@onready var anim_player: AnimationPlayer = $"Escena 0"
@onready var dialogos = get_node("/root/" + get_tree().current_scene.name + "/Dialogos")
@onready var mensaje_label = get_node("/root/" + get_tree().current_scene.name + "/UI/MissionLabel")  # Nodo Label para el mensaje

var mensaje_visible: bool = false
var puede_ocultar_mensaje: bool = false  # Variable para controlar cuándo se puede ocultar el mensaje
var animacion_terminada: bool = false  # Nueva variable para indicar si la animación ha terminado
var wasd_message_shown = false
var wasd_input_detected = false


func _ready():
	if anim_player == null:
		print("Error: El nodo AnimacionIntro no se ha encontrado.")
		return

	player.movable = false
	anim_player.play("Introduccion")
	$"Camara Intro".current = true
	
	# Conectar la señal al final de la animación usando Callable
	anim_player.connect("animation_finished", Callable(self, "_on_animation_finished"))

# Función que se ejecuta al terminar la animación
func _on_cinematic_finished():
	if not wasd_message_shown:
		show_instructions("Presione WASD para moverse")
		wasd_message_shown = true  # El mensaje se ha mostrado una vez


# Función para mostrar el mensaje
func mostrar_mensaje(texto: String):
	if mensaje_label != null and not mensaje_visible:
		mensaje_label.text = texto
		mensaje_label.visible = true  # Hacemos visible el Label
		mensaje_visible = true
		puede_ocultar_mensaje = false  # No permitir ocultar inmediatamente
		print("Mensaje mostrado: ", texto)
		
		# Añadir un pequeño retraso antes de permitir ocultar el mensaje
		await get_tree().create_timer(1.0).timeout  # Esperar 1 segundo
		puede_ocultar_mensaje = true  # Ahora se puede ocultar el mensaje
		print("Se puede ocultar el mensaje ahora")

# Función para ocultar el mensaje
func ocultar_mensaje():
	if mensaje_label != null and mensaje_visible:
		mensaje_label.visible = false
		mensaje_visible = false
		print("Mensaje ocultado")

# Función para verificar las teclas presionadas
func _process(delta):
	if wasd_message_shown and not wasd_input_detected:
		# Si se detecta entrada de movimiento, ocultar el mensaje
		if Input.is_action_pressed("avanzar") or Input.is_action_pressed("atras") or 
		   Input.is_action_pressed("izquierda") or Input.is_action_pressed("derecha"):
			hide_instructions()  # Ocultar el mensaje
			wasd_input_detected = true

# Función para mostrar diálogos
func mostrar_dialogo(texto: String):
	dialogos.mostrar_dialogo(texto)

# Función para ocultar diálogos
func ocultar_dialogo():
	dialogos.ocultar_dialogo()

func hide_instructions():
	if ui_control != null:
		ui_control.update_mission("")  # Deja el mensaje vacío para ocultarlo
