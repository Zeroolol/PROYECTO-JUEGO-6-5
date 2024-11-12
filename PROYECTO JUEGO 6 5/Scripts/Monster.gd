extends CharacterBody3D

var SPEED = 4
var JumpscareTime = 2
var player
var caught = false
var distance: float
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var scene_name: String
@export var patrol_points: Array[Node3D]
var chasing_player = false
var is_player_safe = false  # Nueva variable para la zona segura

# Variables de patrullaje
var patrol_target: Node3D = null

func _ready() -> void:
	player = get_node("/root/" + get_tree().current_scene.name + "/Player/CharacterBody3D")
	if player == null:
		print("Player no encontrado en la escena.")
	if patrol_points.size() == 0:
		print("Advertencia: No hay puntos de patrullaje asignados al enemigo.")
	set_random_patrol_target()

func _physics_process(delta):
	if visible and player and not caught:
		if not is_on_floor():
			velocity.y -= gravity * delta
		else:
			velocity.y = 0

		var current_location = global_transform.origin
		var next_location = $NavigationAgent3D.get_next_path_position()
		distance = player.global_transform.origin.distance_to(current_location)

		if distance <= 15 and not is_player_safe:
			chasing_player = true
			$NavigationAgent3D.target_position = player.global_transform.origin
		else:
			chasing_player = false
			if patrol_target and is_player_safe:
				$NavigationAgent3D.target_position = patrol_target.global_transform.origin
				if current_location.distance_to(patrol_target.global_transform.origin) < 2:
					set_random_patrol_target()

		if next_location != Vector3.ZERO:
			var new_velocity = (next_location - current_location).normalized() * SPEED
			velocity.x = new_velocity.x
			velocity.z = new_velocity.z

			if chasing_player:
				look_at(player.global_transform.origin, Vector3.UP)

		move_and_slide()

		if distance <= 2 and not caught and not is_player_safe:
			trigger_jumpscare()

func set_random_patrol_target():
	if patrol_points.size() > 0:
		patrol_target = patrol_points[randi() % patrol_points.size()]
		print("Nuevo punto de patrullaje: ", patrol_target.name)

func trigger_jumpscare():
	player.visible = false
	caught = true
	SPEED = 0
	velocity = Vector3.ZERO
	$JumpscareCamara.current = true
	await get_tree().create_timer(JumpscareTime, false).timeout
	get_tree().change_scene_to_file("res://Escenas/" + scene_name + ".tscn")

# Métodos para activar/desactivar la zona segura
func player_entered_safe_zone():
	is_player_safe = true
	chasing_player = false
	print("Jugador está en la zona segura.")

func player_exited_safe_zone():
	is_player_safe = false
	print("Jugador ha salido de la zona segura.")
