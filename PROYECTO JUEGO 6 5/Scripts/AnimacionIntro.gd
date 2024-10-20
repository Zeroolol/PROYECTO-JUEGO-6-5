extends Node3D 

@onready var player = get_node("/root/" + get_tree().current_scene.name + "/Player/CharacterBody3D")
@onready var anim_player: AnimationPlayer = $"Escena 0"
@onready var dialogos = get_node("/root/" + get_tree().current_scene.name + "/Dialogos")

func _ready():
	if anim_player == null:
		print("Error: El nodo AnimacionIntro no se ha encontrado.")
		return

	player.movable = false
	anim_player.play("Introduccion")
	$"Camara Intro".current = true

	await get_tree().create_timer(20, false).timeout
	player.movable = true
	player.get_node("Cabeza/Camera3D").current = true
	$"Camara Intro".current = false
	queue_free()

# Función para mostrar diálogos
func mostrar_dialogo(texto: String):
	dialogos.mostrar_dialogo(texto)

# Función para ocultar diálogos
func ocultar_dialogo():
	dialogos.ocultar_dialogo()
