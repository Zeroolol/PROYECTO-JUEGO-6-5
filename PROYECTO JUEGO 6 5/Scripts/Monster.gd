extends CharacterBody3D

enum EnemyState { PATROL, CHASE }

@export var detection_range: float = 10.0
@export var patrol_speed: float = 3.0
@export var chase_speed: float = 6.0
@export var lost_sight_timeout: float = 2.0

@onready var raycast = $RayCast3D
@onready var navigation_agent = $NavigationAgent3D
@onready var detection_area = $DetectionArea
@onready var jumpscare_area = $JumpscareArea

var patrol_points: Array[Marker3D] = []
var current_state = EnemyState.PATROL
var patrol_index = 0
var lost_sight_timer = 0.0
var player

func _ready():
	var main_scene = get_tree().root.get_node("TestingWorld")
	var patrol_points_parent = main_scene.get_node("PatrolPointsParents")
	player = main_scene.get_node("Player/CharacterBody3D")

	for child in patrol_points_parent.get_children():
		if child is Marker3D:
			patrol_points.append(child)

	if patrol_points.size() > 0:
		navigation_agent.target_position = patrol_points[patrol_index].global_transform.origin

	# Conecta las señales de detección y jumpscare
	detection_area.connect("body_entered", Callable(self, "_on_detection_area_body_entered"))
	jumpscare_area.connect("body_entered", Callable(self, "_on_jumpscare_area_body_entered"))

	raycast.enabled = true

func _process(delta):
	match current_state:
		EnemyState.PATROL:
			patrol(delta)
		EnemyState.CHASE:
			chase_player(delta)

func patrol(delta):
	if navigation_agent.is_target_reached():
		patrol_index = (patrol_index + 1) % patrol_points.size()
		navigation_agent.target_position = patrol_points[patrol_index].global_transform.origin

	if is_player_in_range():
		current_state = EnemyState.CHASE
		lost_sight_timer = 0.0

	var direction = (navigation_agent.get_next_path_position() - global_transform.origin).normalized()
	velocity = direction * patrol_speed
	move_and_slide()

	if direction.length() > 0.1:
		look_at(global_transform.origin - direction, Vector3.UP)

func chase_player(delta):
	if is_player_in_range():
		navigation_agent.target_position = player.global_transform.origin
		lost_sight_timer = 0.0

		# Asegura que el enemigo esté siguiendo la ruta
		if not navigation_agent.path.is_empty():
			var direction = (navigation_agent.get_next_path_position() - global_transform.origin).normalized()
			velocity = direction * chase_speed
			move_and_slide()

			if global_transform.origin.distance_to(player.global_transform.origin) < 1.0:
				go_to_death_screen()
	else:
		lost_sight_timer += delta
		if lost_sight_timer >= lost_sight_timeout:
			start_patrolling()

func is_player_in_range() -> bool:
	if player == null:
		return false

	var distance_to_player = global_transform.origin.distance_to(player.global_transform.origin)
	if distance_to_player > detection_range:
		return false

	# Orienta el raycast hacia el jugador
	raycast.target_position = (player.global_transform.origin - global_transform.origin).normalized()
	raycast.force_raycast_update()

	if raycast.is_colliding() and raycast.get_collider() == player:
		return true
	return false

func start_patrolling():
	current_state = EnemyState.PATROL
	navigation_agent.target_position = patrol_points[patrol_index].global_transform.origin

func go_to_death_screen():
	get_tree().change_scene_to_file("res://Escenas/PantallaMuerte.tscn")

func _on_detection_area_body_entered(body: Node3D) -> void:
	if body == player:
		current_state = EnemyState.CHASE

func _on_jumpscare_area_body_entered(body: Node3D) -> void:
	if body == player:
		go_to_death_screen()
