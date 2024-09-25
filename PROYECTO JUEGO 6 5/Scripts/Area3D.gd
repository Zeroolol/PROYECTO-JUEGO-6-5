extends Area3D

@onready var animation = $"../AnimacionBaño/Escena1"
@onready var cinematic_camera = $"../AnimacionBaño/CamaraBaño"
@onready var player_camera = $"../Player/CharacterBody3D/Cabeza/Camera3D"  # Ajusta la ruta a la cámara del jugador

func _ready():
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		# Activar la cámara de la cinemática
		if cinematic_camera:
			cinematic_camera.current = true

		animation.play("AnimacionBaño")
		animation.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name):
	get_tree().change_scene_to_file("res://Escenas/testing_world.tscn")
