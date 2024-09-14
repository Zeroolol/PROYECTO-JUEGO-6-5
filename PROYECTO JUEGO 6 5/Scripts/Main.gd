extends Node3D

@onready var player = $Player/CharacterBody3D
@onready var audio_player = $"Ambient Sound/Tren"
@onready var timer = $Timer

func _ready():
	# Conecta la señal `timeout` del Timer a la función `_on_timer_timeout`
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	# Reproduce el sonido al iniciar la escena
	_play_ambient_sound()
	
func _on_timer_timeout():
	# Reproduce el sonido ambiente cuando el temporizador se activa
	_play_ambient_sound()
	
func _play_ambient_sound():
	if audio_player:
		audio_player.play()


func _physics_process(delta):
	var player_position = player.global_transform.origin
	print("Posición del jugador:", player_position)
	get_tree().call_group("Enemy", "update_target_location", player_position)
