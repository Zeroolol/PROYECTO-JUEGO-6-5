extends Node3D

@onready var mission_ui: Node = get_node("/root/TestingWorld/UI")  # Obtener el nodo UI
@onready var control_dialogos: Control = get_node("/root/TestingWorld/Dialogos")  # Nodo para los diálogos
@onready var label_dialogo: RichTextLabel = control_dialogos.get_node("Panel/DialogoTexto")  # Label dentro del Panel

# Lista de diálogos
var dialogos = [
	"ahg que paso ? me la re di",
	"uh lpm ya es de noche ?",
	"Capaz los chicos siguen en clases"
]

var indice_dialogo = 0  # Lleva el control del diálogo actual

func _ready():
	$"animacion escena".play("comienzo")
	$"camara escena".current = true

	await get_tree().create_timer(9.0, false).timeout

	# Restablecer la cámara y la movilidad del jugador
	var player = get_node("/root/TestingWorld/Player/CharacterBody3D")
	player.movable = true
	player.get_node("Cabeza/Camera3D").current = true
	$"camara escena".current = false

	# Mostrar el primer diálogo
	if control_dialogos and label_dialogo:
		control_dialogos.visible = true
		label_dialogo.text = dialogos[indice_dialogo]

func _process(delta):
	if Input.is_action_just_pressed("Aceptar"):  # Aquí puedes usar cualquier tecla que prefieras
		avanzar_dialogo()

func avanzar_dialogo():
	indice_dialogo += 1  # Avanza al siguiente diálogo

	if indice_dialogo < dialogos.size():
		# Actualiza el texto del siguiente diálogo
		label_dialogo.text = dialogos[indice_dialogo]
	else:
		# Si ya no hay más diálogos, ocultar el panel
		control_dialogos.visible = false
		# Mostrar la misión después de los diálogos
		actualizar_mision()

func actualizar_mision():
	# Actualizar la misión aquí después de los diálogos
	if mission_ui:
		mission_ui.update_mission("Regresa al aula")
	else:
		print("Error: Nodo UI no encontrado.")
