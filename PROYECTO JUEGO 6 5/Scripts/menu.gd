extends Control

func _ready():
	pass
	
	


func _on_inicio_pressed():
	get_tree().change_scene_to_file("res://Escenas/tutorial.tscn")
	


func _on_salir_pressed():
	get_tree().quit()



func _on_opciones_pressed():
	get_tree().change_scene_to_file("res://Escenas/Options_menu.tscn")
