extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	pass
	



func _on_confirmar_pressed():
	AudioServer.set_bus_volume_db(0, linear_to_db($AudioSetting/Master.value))
	AudioServer.set_bus_volume_db(0, linear_to_db($AudioSetting/Ambiente.value))
	AudioServer.set_bus_volume_db(0, linear_to_db($AudioSetting/SFX.value))

func _on_atras_pressed():
	get_tree().change_scene_to_file("res://Escenas/menu.tscn")
