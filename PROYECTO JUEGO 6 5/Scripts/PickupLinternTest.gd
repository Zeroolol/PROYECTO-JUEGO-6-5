extends StaticBody3D

@export var item_resource: ItemResource 

var flashlight  # Referencia a la linterna en la escena

func _ready():
	# Ruta hacia la linterna en el jugador
	var player_node_path = "/root/" + get_tree().current_scene.name + "/Player/CharacterBody3D/Cabeza/Camera3D/FlashLight"
	flashlight = get_node(player_node_path)

func interact():
	if flashlight:
		flashlight.picked_up = true  # Marca la linterna como recogida
		
		# Agregar la linterna al inventario
		var inventory = get_node("/root/TestingWorld/Inventario")  # Asegúrate de que la ruta al inventario es correcta
		inventory.add_item(item_resource)  # Agrega el item al inventario
		
		queue_free()  # Elimina la linterna de la escena después de recogerla
	else:
		print("Flashlight not found!")
