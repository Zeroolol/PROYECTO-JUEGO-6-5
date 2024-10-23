extends Node3D

@onready var aula_area: Area3D = get_node("/root/TestingWorld/AulaArea")  # Área que define el aula
@onready var dialog_node: Label = get_node("/root/TestingWorld/Dialogos/Panel/TextoDialogo")  # Nodo del diálogo
@onready var panel_dialogo: Panel = get_node("/root/TestingWorld/Dialogos/Panel")  # Panel del diálogo
@onready var mensaje_label: Label = get_node("/root/TestingWorld/Dialogos/MensajeMission")  # Nodo para el mensaje final

# Diálogos a mostrar
var dialogos: Array = ["uh que pasó, me la re di", "ya es de noche?", "capaz los chicos siguen en clases..."]
var dialog_index: int = 0  # Índice para el diálogo actual

# Indica si estamos en modo diálogo
var en_dialogo: bool = false

func _ready():
	# Iniciar animación de escena
	$"animacion escena".play("comienzo")
	$"camara escena".current = true

	# Espera hasta que termine la animación (9 segundos en este caso)
	await get_tree().create_timer(9.0, false).timeout

	# Habilitar al jugador después de la animación
	var player = get_node("/root/TestingWorld/Player/CharacterBody3D") as CharacterBody3D
	if player:
		player.movable = true
		player.get_node("Cabeza/Camera3D").current = true
		$"camara escena".current = false

	# Iniciar secuencia de diálogos
	await mostrar_siguiente_dialogo()

# Función para mostrar el siguiente diálogo
func mostrar_siguiente_dialogo():
	if dialog_index < dialogos.size():
		en_dialogo = true  # Activar el modo diálogo
		panel_dialogo.visible = true  # Mostrar el panel de diálogo
		dialog_node.text = dialogos[dialog_index]  # Mostrar el diálogo actual
	else:
		# Cuando todos los diálogos hayan sido mostrados, ocultar el panel
		panel_dialogo.visible = false
		en_dialogo = false  # Desactivar el modo diálogo
		mostrar_mensaje_final()  # Llamar a la función para mostrar el mensaje final

# Función para mostrar el mensaje final
func mostrar_mensaje_final():
	mensaje_label.text = "REGRESA AL AULA"  # Cambia el texto aquí
	mensaje_label.visible = true  # Hacer visible el Label del mensaje
	await get_tree().create_timer(3.0).timeout  # Opcional: Ocultar el mensaje después de 3 segundos
	mensaje_label.visible = false  # Ocultar el mensaje después de la espera

# Escuchar la entrada del jugador
func _process(delta):
	if en_dialogo and Input.is_action_just_pressed("Aceptar"):  # 'ui_accept' suele ser Enter o Espacio
		dialog_index += 1  # Pasar al siguiente diálogo
		mostrar_siguiente_dialogo()  # Mostrar el siguiente diálogo
