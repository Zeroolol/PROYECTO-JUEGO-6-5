extends CharacterBody3D

# Nodos de AudioStreamPlayer para los sonidos
@onready var walk_sound_player = $"CaminarMonster"  # Asegúrate de tener este nodo en la escena
@onready var run_sound_player = $"CorrerMonster"  # Asegúrate de tener este nodo en la escena

# Otros atributos del enemigo
enum EnemyState {WANDER, CHASE, SEARCH}
var current_state: EnemyState = EnemyState.WANDER

@export var patrol_speed: float = 6
@export var chase_speed: float = 13.0
@export var search_time: float = 5.0  # Tiempo que busca al jugador
@export var lost_sight_time: float = 10.0  # Tiempo para perder de vista al jugador
@export var player: CharacterBody3D
@export var patrol_points_parent: Node3D  # Nodo padre de los puntos de patrullaje
@export var detection_range: float = 30.0  # Distancia máxima a la que el enemigo puede detectar al jugador
@export var lost_sight_timeout: float = 30.0  # Tiempo límite sin ver al jugador

var patrol_points: Array = []
var last_patrol_index: int = -1  # Para recordar el último índice patrullado
var patrol_target: Vector3
var search_timer: float = 0.0  # Declarar search_timer a nivel de clase
var lost_sight_timer: float = 0.0  # Temporizador para perder de vista al jugador
var has_lost_sight: bool = false  # Indica si ha perdido la vista del jugador

# Umbral de proximidad para considerar que se ha alcanzado el punto de patrulla
const PATROL_POINT_THRESHOLD = 2.0

# Agente de navegación para evitar obstáculos
var navigation_agent: NavigationAgent3D

# Variable para el AnimationPlayer
@onready var animation_player = $"CollisionShape3D/CRIATURA_FEA (3)/AnimationPlayer"  # Ajusta según tu estructura de nodos

func _ready():
	# Inicializar el NavigationAgent3D
	navigation_agent = $NavigationAgent3D

	# Asegurarse de que patrol_points_parent tiene nodos hijos
	if patrol_points_parent:
		patrol_points = patrol_points_parent.get_children().filter(func(child):
			return child is Marker3D
		)

		# Si hay puntos de patrullaje, establecer el primer objetivo
		if patrol_points.size() > 0:
			patrol_target = get_next_patrol_point()
			navigation_agent.target_location = patrol_target  # Establecer el destino en el agente

	# Conexiones para los detectores
	$JumpscareDetector.connect("body_entered", Callable(self, "_on_jumpscare_detector_body_entered"))
	$Detector.connect("body_entered", Callable(self, "_on_detector_body_entered"))
	$BiggerDetector.connect("body_entered", Callable(self, "_on_bigger_detector_body_entered"))

	start_wandering()

func _process(delta):
	if is_player_in_range():
		current_state = EnemyState.CHASE
		lost_sight_timer = 0.0  # Reinicia el temporizador cuando ve al jugador
	else:
		lost_sight_timer += delta  # Incrementa el temporizador cuando no ve al jugador
		if lost_sight_timer >= lost_sight_timeout:
			start_wandering()  # Cambia a patrullaje si supera el tiempo límite
		else:
			current_state = EnemyState.WANDER

	# Lógica para el cambio de estados
	match current_state:
		EnemyState.WANDER:
			wander(delta)
		EnemyState.CHASE:
			chase_player(delta)
func is_player_in_range() -> bool:
	var distance_to_player = global_transform.origin.distance_to(player.global_transform.origin)
	return distance_to_player <= detection_range  # Verifica si el jugador está dentro del rango
	# Verificar si el jugador es visible en cada frame
	if is_player_visible():
		current_state = EnemyState.CHASE
	elif current_state == EnemyState.CHASE and not is_player_visible():
		current_state = EnemyState.SEARCH  # Cambia a buscar si el jugador ya no es visible

# Estados

func start_wandering():
	current_state = EnemyState.WANDER
	patrol_target = get_next_patrol_point()
	navigation_agent.target_location = patrol_target  # Actualiza el destino del agente
	animation_player.play("Patrullaje")  # Reproducir animación de caminar
	play_walk_sound()  # Iniciar sonido de caminar

func wander(delta):
	if is_at_patrol_point():
		patrol_target = get_next_patrol_point()  # Seleccionar un nuevo objetivo al llegar a uno
		navigation_agent.target_location = patrol_target  # Actualiza el destino del agente

	move_with_navigation(delta, patrol_speed)

func chase_player(delta):
	if player and is_player_in_range():  # Si el jugador está dentro del rango de detección
		var player_pos = player.global_transform.origin
		navigation_agent.target_location = player_pos  # Establecer el destino como el jugador
		move_with_navigation(delta, chase_speed)
		animation_player.play("Correr")  # Reproducir animación de correr
		play_run_sound()
		
		if is_in_jumpscare_range():
			kill_player()
	else:
		start_wandering()  # Regresar a patrullar si el jugador sale del rango

func search_for_player(delta):
	search_timer -= delta
	if search_timer <= 0:
		start_wandering()

# Movimiento con navegación
func move_with_navigation(delta, speed: float):
	if not navigation_agent.is_navigation_finished():
		var direction = navigation_agent.get_next_path_position() - global_transform.origin
		direction = direction.normalized()

		# Girar el enemigo hacia la dirección de movimiento
		rotate_towards_direction(direction, delta)

		# Calcular la velocidad
		velocity = direction * speed
		move_and_slide()  # Mueve al enemigo usando la ruta calculada por el agente

		# Reproducir animación de caminar si se está moviendo
		if direction.length() > 0:  # Si hay movimiento
			if current_state == EnemyState.WANDER:
				play_walk_sound()  # Reproducir sonido de caminar si está patrullando
				animation_player.play("Patrullaje")  # Asegúrate de que esta animación exista
			elif current_state == EnemyState.CHASE:
				animation_player.play("Correr")  # Reproducir animación de correr
		else:
			animation_player.stop()  # Detener la animación si no hay movimiento
			stop_walk_sound()  # Detener sonido de caminar si no se mueve

# Reproducir sonido de caminar
func play_walk_sound():
	if not walk_sound_player.is_playing():
		walk_sound_player.play()

# Detener sonido de caminar
func stop_walk_sound():
	if walk_sound_player.is_playing():
		walk_sound_player.stop()

# Reproducir sonido de correr
func play_run_sound():
	if not run_sound_player.is_playing():
		run_sound_player.play()

# Detener sonido de correr
func stop_run_sound():
	if run_sound_player.is_playing():
		run_sound_player.stop()

# Función para girar suavemente hacia la dirección de movimiento
func rotate_towards_direction(direction: Vector3, delta: float):
	var current_rotation = global_transform.basis.get_euler()
	var target_rotation = current_rotation

	# Obtener la rotación hacia la dirección de movimiento (en el eje Y)
	var look_at_rotation = global_transform.looking_at(global_transform.origin + direction, Vector3.UP).basis.get_euler()

	# Invertir la rotación si el enemigo está girando hacia atrás (dependiendo de la orientación del modelo)
	look_at_rotation.y += PI  # Ajusta el ángulo Y sumando 180 grados (PI radianes)

	# Interpolar suavemente la rotación en el eje Y
	target_rotation.y = lerp_angle(current_rotation.y, look_at_rotation.y, 5.0 * delta)

	# Aplicar la nueva rotación
	global_transform.basis = Basis().from_euler(target_rotation)

func get_next_patrol_point() -> Vector3:
	if patrol_points.size() > 0:
		var random_index: int
		random_index = randi() % patrol_points.size()
		while random_index == last_patrol_index:
			random_index = randi() % patrol_points.size()

		last_patrol_index = random_index
		return patrol_points[random_index].global_transform.origin
	else:
		return global_transform.origin  # Fallback

func is_at_patrol_point() -> bool:
	return global_transform.origin.distance_to(patrol_target) < PATROL_POINT_THRESHOLD

func is_in_jumpscare_range() -> bool:
	return global_transform.origin.distance_to(player.global_transform.origin) <= 2.0

func kill_player():
	get_tree().change_scene_to_file("res://Escenas/PantallaMuerte.tscn")

func player_is_running() -> bool:
	if player.has_method("get_walk_speed"):
		return player.velocity.length() > player.get_walk_speed()
	return false

# Detectores
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

func is_player_visible() -> bool:
	var direction_to_player = (player.global_transform.origin - global_transform.origin).normalized()
	var distance_to_player = global_transform.origin.distance_to(player.global_transform.origin)

	# Crear parámetros de raycast
	var ray_parameters = PhysicsRayQueryParameters3D.new()
	ray_parameters.from = global_transform.origin
	ray_parameters.to = player.global_transform.origin

	# Realiza el raycast
	var result = get_world_3d().direct_space_state.intersect_ray(ray_parameters)

	# El jugador es visible solo si no hay ningún objeto entre ellos y está dentro del rango de detección
	return result.size() == 0 and distance_to_player <= detection_range
