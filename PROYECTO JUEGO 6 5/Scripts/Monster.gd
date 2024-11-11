extends CharacterBody3D

var SPEED = 4
var JumpscareTime = 2
var player
var caught = false
var distance: float
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var scene_name: String

func _ready() -> void:
	player = get_node("/root/" + get_tree().current_scene.name + "/Player/CharacterBody3D")
	if player == null:
		print("Player no encontrado en la escena.")

func _physics_process(delta):
	if visible and player and not caught:
		if not is_on_floor():
			velocity.y -= gravity * delta

		var current_location = global_transform.origin
		var next_location = $NavigationAgent3D.get_next_path_position()

		# Actualiza el target_position hacia el jugador si está en el rango
		distance = player.global_transform.origin.distance_to(current_location)
		if distance <= 15:  # Ajusta el rango de detección según sea necesario
			$NavigationAgent3D.target_position = player.global_transform.origin
		
		# Mueve al enemigo en dirección al target
		var new_velocity = (next_location - current_location).normalized() * SPEED
		$NavigationAgent3D.set_velocity(new_velocity)
		velocity = new_velocity

		# Gira el enemigo hacia el jugador usando look_at
		var direction_to_player = player.global_transform.origin
		look_at(direction_to_player, Vector3.UP)

		# Verifica si está lo suficientemente cerca para "atrapar" al jugador
		if distance <= 2 and not caught:
			player.visible = false
			caught = true
			SPEED = 0  # Detener al enemigo al atraparlo
			$NavigationAgent3D.set_velocity(Vector3.ZERO)  # Detener el agente de navegación
			velocity = Vector3.ZERO  # Detener el movimiento del cuerpo del enemigo

			$JumpscareCamara.current = true
			await get_tree().create_timer(JumpscareTime, false).timeout
			get_tree().change_scene_to_file("res://Escenas/" + scene_name + ".tscn")

func update_target_location(target_location):
	$NavigationAgent3D.target_position = target_location
	
func on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = velocity.move_toward(safe_velocity, 0.25)
	move_and_slide()
