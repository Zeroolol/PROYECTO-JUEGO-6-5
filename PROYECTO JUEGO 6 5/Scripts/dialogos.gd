extends Control  # Dialogos

@onready var dialog_label: Label = $Panel/TextoDialogo  # Obtener referencia al Label
@onready var panel_dialogo: Panel = $Panel  # Obtener referencia al Panel
@onready var mensaje_label: Label = $MensajeMission  # Obtener referencia al Label de la misión
@onready var audio_player: AudioStreamPlayer3D = get_node("/root/TestingWorld/Sounds/MonsterFondo1")  # Ruta al AudioStreamPlayer en la escena principal

var dialogos: Array = ["eh ? no hay nadie", "ademas esta re baqueteado el colegio", "capaz en secretaria sepan algo"]  # Lista de diálogos
var dialog_index: int = 0  # Índice para el diálogo actual
var en_dialogo: bool = false  # Indica si el diálogo está activo

func _ready():
	panel_dialogo.visible = false  # Oculta el panel al inicio
	mensaje_label.visible = false  # Oculta el mensaje de misión al inicio

# Función para iniciar el diálogo
func iniciar_dialogo():
	if dialog_index == 0:  # Solo iniciar la secuencia de diálogos si es la primera vez
		dialog_index = 0
		en_dialogo = true  # Activa el modo diálogo
		await mostrar_siguiente_dialogo()  # Comienza a mostrar los diálogos

# Función para mostrar el diálogo actual
func mostrar_siguiente_dialogo():
	if dialog_index < dialogos.size():
		mostrar_dialogo(dialogos[dialog_index])  # Muestra el diálogo correspondiente
	else:
		ocultar_dialogo()  # Si no hay más diálogos, oculta el panel y termina el modo diálogo
		en_dialogo = false  # Finaliza el modo diálogo
		mostrar_mensaje_final()  # Llama a la función para mostrar el mensaje final

# Función para mostrar el mensaje final
func mostrar_mensaje_final():
	mensaje_label.text = "VE A SECRETARIA"  # Actualizar el texto del mensaje de misión
	mensaje_label.visible = true  # Hacer visible el Label del mensaje
	await get_tree().create_timer(3.0).timeout  # Esperar 3 segundos
	mensaje_label.visible = false  # Ocultar el mensaje después de la espera

	# Llama a la función para reproducir el sonido después de 5 segundos
	await get_tree().create_timer(5.0).timeout
	reproducir_sonido()

# Función para reproducir el sonido
func reproducir_sonido():
	if audio_player:  # Verificar si el nodo de audio está asignado
		audio_player.play()  # Reproducir el sonido

# Función para mostrar el diálogo
func mostrar_dialogo(texto: String):
	panel_dialogo.visible = true  # Hacer visible el panel
	dialog_label.text = texto  # Cambia el texto del Label para mostrar el diálogo

# Función para ocultar el diálogo
func ocultar_dialogo():
	panel_dialogo.visible = false  # Hacer invisible el panel
	dialog_label.text = ""  # Limpia el texto del diálogo

# Función para mostrar un diálogo específico cuando se interactúa con la caja
func mostrar_dialogo_fusible(texto: String, mensaje_mission: String = ""):
	mostrar_dialogo(texto)  # Mostrar el texto del diálogo
	if mensaje_mission != "":
		mensaje_label.text = mensaje_mission  # Mostrar mensaje de misión si es necesario
		mensaje_label.visible = true  # Hacer visible el mensaje de misión
		await get_tree().create_timer(3.0).timeout  # Esperar 3 segundos
		mensaje_label.visible = false  # Ocultar el mensaje de misión

# Función para procesar la entrada del jugador
func _process(delta):
	if en_dialogo and Input.is_action_just_pressed("Aceptar"):  # Detecta si se presiona "Aceptar"
		dialog_index += 1  # Pasa al siguiente diálogo
		mostrar_siguiente_dialogo()  # Muestra el siguiente diálogo
