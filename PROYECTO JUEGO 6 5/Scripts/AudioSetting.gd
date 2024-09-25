extends Control

func _ready():
	$Master.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	$Ambiente.value = db_to_linear(AudioServer.get_bus_volume_db(1))
	$SFX.value = db_to_linear(AudioServer.get_bus_volume_db(2))

func _on_sfx_mouse_exited():
	release_focus()

func _on_ambiente_mouse_exited():
	release_focus()

func _on_master_mouse_exited():
	release_focus()
