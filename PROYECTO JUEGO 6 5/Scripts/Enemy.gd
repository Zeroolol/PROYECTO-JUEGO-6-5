extends CharacterBody3D

# Estados del enemigo
enum EnemyState {WANDER, CHASE, SEARCH}
var current_state: EnemyState = EnemyState.WANDER

@export var patrol_speed: float = 2.0
@export var chase_speed: float = 4.0
@export var search_time: float = 5.0  # Tiempo que busca al jugador
@export var player: CharacterBody3D
var search_timer: float = 0.0
var patrol_target: Vector3
var searching = false

func _ready():
	if not $JumpscareDetector.is_connected("body_entered", Callable(self, "_on_jumpscare_detector_body_entered")):
		$JumpscareDetector.connect("body_entered", Callable(self, "_on_jumpscare_detector_body_entered"))
	
	if not $Detector.is_connected("body_entered", Callable(self, "_on_detector_body_entered")):
		$Detector.connect("body_entered", Callable(self, "_on_detector_body_entered"))
	if not $BiggerDetector.is_connected("body_entered", Callable(self, "_on_bigger_detector_body_entered")):
		$BiggerDetector.connect("body_entered", Callable(self, "_on_bigger_detector_body_entered"))
	
	start_wandering()

<<<<<<< HEAD

func _process(delta):
=======
func _physics_process(delta):
>>>>>>> c022759e1fdd9104446256fd027eba7ea6549785
	match current_state:
		EnemyState.WANDER:
			$JumpscareDetector.monitoring = false
			$BiggerDetector.monitoring = true
			$Detector.monitoring = false
			wander(delta)
		EnemyState.CHASE:
			$JumpscareDetector.monitoring = true
			$BiggerDetector.monitoring = false
			$Detector.monitoring = false
			chase_player(delta)
		EnemyState.SEARCH:
			$JumpscareDetector.monitoring = false
			$BiggerDetector.monitoring = false
			$Detector.monitoring = true
			search_for_player(delta)


func start_wandering():
	current_state = EnemyState.WANDER
	patrol_target = get_random_patrol_point()

func wander(delta):
	if is_at_patrol_point():
		patrol_target = get_random_patrol_point()
	move_towards(patrol_target, patrol_speed)

func chase_player(delta):
	if player:
		var player_pos = player.global_transform.origin
		move_towards(player_pos, chase_speed)
		if is_in_jumpscare_range():
			kill_player()

func search_for_player(delta):
	search_timer -= delta
	if search_timer <= 0:
		start_wandering()

func move_towards(target: Vector3, speed: float):
	var direction = (target - global_transform.origin).normalized()
	var target_velocity = direction * speed
	if velocity != target_velocity:
		velocity = target_velocity
		move_and_slide()

func is_in_jumpscare_range() -> bool:
	return global_transform.origin.distance_to(player.global_transform.origin) <= 2.0

func get_random_patrol_point() -> Vector3:
	return Vector3(randf_range(-10, 10), 0, randf_range(-10, 10))

func is_at_patrol_point() -> bool:
	return global_transform.origin.distance_to(patrol_target) < 0.5

func kill_player():
	get_tree().change_scene_to_file("res://Escenas/PantallaMuerte.tscn")

func player_is_running() -> bool:
	return player.velocity.length() > player.walk_speed

func _on_jumpscare_detector_body_entered(body: Node3D) -> void:
	if body == player:
		kill_player()

func _on_bigger_detector_body_entered(body: Node3D) -> void:
	if body == player:
		current_state = EnemyState.CHASE

func _on_detector_body_entered(body: Node3D) -> void:
	if body == player and player_is_running():
		current_state = EnemyState.SEARCH
		search_timer = search_time
		patrol_target = player.global_transform.origin
