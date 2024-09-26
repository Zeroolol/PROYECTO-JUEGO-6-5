extends Node3D

@onready var control_dialogos: Control = get_node("/root/Tutorial/Dialogos")
@onready var label_dialogo: RichTextLabel = control_dialogos.get_node("Panel/DialogoTexto")
@onready var player = get_node("/root/" + get_tree().current_scene.name + "/Player/CharacterBody3D")  # Obtener referencia al jugador

var dialogos = [
	"Profe, ¿puedo ir al baño? Me duele la cabeza.",
	"No puede salir en horario de clase.",
	"Por favor, me está reventando la cabeza.",
	"Bueno, dale, pero vuelve rápido que me cagan a pedo si no.",
	"Gracias profe.",
]

var indice_dialogo = 0

func _ready():
	$AnimacionIntro.play("Introduccion")
	$"Camara Intro".current = true
	await get_tree().create_timer(20, false).timeout
	player.movable = true
	player.get_node("Cabeza/Camera3D").current = true
	$"Camara Intro".current = false
	queue_free()

	# Iniciar la secuencia de diálogos después de la animación
	mostrar_dialogo()

func mostrar_dialogo():
	if indice_dialogo < dialogos.size():
		control_dialogos.visible = true
		label_dialogo.text = dialogos[indice_dialogo]
		
		# Determinar el tiempo de espera para el último diálogo
		var tiempo_espera: float
		if indice_dialogo == dialogos.size() - 1:
			tiempo_espera = 2.0  # 2 segundos para el último
		else:
			tiempo_espera = 5.0  # 5 segundos para los demás

		# Esperar antes de ocultar el diálogo
		await get_tree().create_timer(tiempo_espera, false).timeout
		
		indice_dialogo += 1
		
		# Llamar de nuevo a mostrar_dialogo para el siguiente diálogo
		mostrar_dialogo()
	else:
		control_dialogos.visible = false  # Ocultar el panel después de todos los diálogos
		player.show_instructions()  # Llamar a la función para mostrar las instrucciones en el jugador
