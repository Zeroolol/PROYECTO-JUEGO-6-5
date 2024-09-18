extends CharacterBody3D

@export var navigation_region: NodePath  # Ruta al NavigationRegion3D
@export var patrol_speed: float = 4.0  # Velocidad de movimiento durante la patrulla
@export var detection_range: float = 10.0  # Rango de detección del jugador
@export var player: CharacterBody3D  # Referencia al jugador
@export var kill_range: float = 2.0  # Rango en el que el enemigo mata al jugador
var inventory: Node
var grid_container: GridContainer

var patrol_target: Vector3  # Posición a la que se moverá el enemigo durante la patrulla
var chasing_player = false

func _ready():
	# Obtener el nodo NavigationRegion3D
	var region = get_node(navigation_region) as NavigationRegion3D
	if region:
		patrol_target = get_random_point_in_region(region)  # Obtener un punto aleatorio para patrullar
		$NavigationAgent3D.target_position = patrol_target

func _process(delta):
	if detect_player():
		chasing_player = true
		$NavigationAgent3D.target_position = player.global_transform.origin
	else:
		chasing_player = false

	if chasing_player:
		# Perseguir al jugador
		$NavigationAgent3D.target_position = player.global_transform.origin
		if is_within_kill_range():
			print("Enemigo está dentro del rango de matar al jugador.")
			kill_player()
	else:
		# Patrullar dentro de la región
		patrol(delta)

	# Mover al enemigo hacia el objetivo usando move_and_slide()
	var next_position = $NavigationAgent3D.get_next_path_position()
	if next_position:
		var direction = (next_position - global_transform.origin).normalized()
		velocity = direction * patrol_speed  # Establece la velocidad con base en la dirección y la velocidad de patrullaje
		move_and_slide()  # Mueve el CharacterBody3D usando la velocidad

func patrol(delta):
	# Si ha llegado al punto de patrullaje, generar un nuevo punto aleatorio dentro de la región
	if $NavigationAgent3D.is_navigation_finished():
		var region = get_node(navigation_region) as NavigationRegion3D
		patrol_target = get_random_point_in_region(region)
		$NavigationAgent3D.target_position = patrol_target

func detect_player() -> bool:
	# Detectar al jugador por distancia
	var distance_to_player = global_transform.origin.distance_to(player.global_transform.origin)
	return distance_to_player <= detection_range

func is_within_kill_range() -> bool:
	# Comprobar si el enemigo está dentro del rango de matar al jugador
	var distance_to_player = global_transform.origin.distance_to(player.global_transform.origin)
	return distance_to_player <= kill_range

func get_random_point_in_region(region: NavigationRegion3D) -> Vector3:
	# Obtener el nodo CollisionShape3D asociado a la región
	var collision_shape = get_node("/root/TestingWorld/Enemy/CharacterBody3D/Colision_de_enemigo") as CollisionShape3D
	
	if collision_shape:
		# Obtener la forma como BoxShape3D
		var shape = collision_shape.shape as BoxShape3D
		if shape:
			# Obtener las extents del BoxShape3D
			var extents = shape.extents
			
			# Calcular el centro (en este caso asumimos que está en el origen del CollisionShape3D)
			var center = collision_shape.global_transform.origin
			
			# Generar un punto aleatorio dentro del volumen de la caja
			var random_point = Vector3(
				randf_range(center.x - extents.x, center.x + extents.x),
				randf_range(center.y - extents.y, center.y + extents.y),
				randf_range(center.z - extents.z, center.z + extents.z)
			)

			return random_point
		else:
			return global_transform.origin  # Si no hay una BoxShape3D, retorna la posición actual
	else:
		return global_transform.origin  # Si no hay CollisionShape3D, retorna la posición actual

func kill_player():
	if player:
		# Cambiar a la pantalla de muerte
		get_tree().change_scene_to_file("res://Escenas/PantallaMuerte.tscn")  # Cambia esto por la ruta correcta de tu escena de muerte
		print("Jugador ha sido eliminado. Cambiando a la pantalla de muerte.")
