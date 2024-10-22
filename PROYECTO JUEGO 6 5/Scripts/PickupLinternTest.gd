extends StaticBody3D

@export var item_resource: ItemResource 

var flashlight  # Referencia a la linterna en la escena
var lights_node_path = "/root/TestingWorld/Lights"  # Ruta al nodo de luces
@onready var audio_player: AudioStreamPlayer3D = get_node("/root/TestingWorld/Sounds/CorteLuz")  # Ruta al AudioStreamPlayer

func _ready():
	# Ruta hacia la linterna en el jugador
	var player_node_path = "/root/" + get_tree().current_scene.name + "/Player/CharacterBody3D/Cabeza/Camera3D/FlashLight"
	flashlight = get_node(player_node_path)

func interact(jugador):
	if flashlight:
		flashlight.picked_up = true  # Marca la linterna como recogida
		
		# Agregar la linterna al inventario
		var inventory = get_node("/root/TestingWorld/Inventario")  # Asegúrate de que la ruta al inventario es correcta
		inventory.add_item(item_resource)  # Agrega el item al inventario
		
		queue_free()  # Elimina la linterna de la escena después de recogerla

		# Notificar a la escena principal para que apague las luces
		var lights_node = get_node(lights_node_path)
		if lights_node:
			lights_node.visible = false  # Hacer que el nodo Lights deje de ser visible
			audio_player.play()  # Reproducir el sonido
