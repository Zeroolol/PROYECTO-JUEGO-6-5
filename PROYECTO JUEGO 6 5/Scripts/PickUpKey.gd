extends StaticBody3D

@export var item_resource: ItemResource  # Recurso de la llave

func interact():
	var inventory = get_node("/root/TestingWorld/Inventario")
	if inventory:
		print("Agregando ítem: ", item_resource.item_name, " con textura: ", item_resource.texture)
		inventory.add_item(item_resource)  # Agrega el ítem al inventario
		queue_free()  # Elimina la llave de la escena
	else:
		print("Inventario no encontrado")
