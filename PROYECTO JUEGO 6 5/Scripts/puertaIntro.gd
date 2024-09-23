extends Node3D

var interactable = true
@onready var cinematic_camera: Camera3D = get_tree().get_root().get_node("CamaraBaño")  # Ajusta el camino si es necesario
@onready var new_scene: PackedScene = preload("res://Escenas/testing_world.tscn")
@onready var animacion: AnimationPlayer = $Bisagra/StaticBody3D/AnimacionIB  # Asegúrate de que esta referencia sea correcta

func interact():
	if interactable:
		interactable = false  # Desactivar la interacción mientras se reproduce la cinemática
		play_cinematic()

func play_cinematic() -> void:
	# Cambia a la cámara de la cinemática
	cinematic_camera.current = true
	animacion.play("AnimacionBaño")  # Reproduce la cinemática que contiene abrir y cerrar la puerta

	# E##espera a que termine la animación de la cinemática
	await get_tree().create_timer(animacion.get_current_animation_length(), false).timeout
	
	# Cambia a la nueva escena
	get_tree().change_scene_to(new_scene)
	
	# Restablece la puerta a su estado interactivo después de la cinemática
	interactable = true
