extends CharacterBody3D

@export var navigation_region: NodePath  # Ruta al NavigationRegion3D
@export var patrol_speed: float = 4.0  # Velocidad de movimiento durante la patrulla
@export var detection_range: float = 10.0  # Rango de detección del jugador
@export var player: CharacterBody3D  # Referencia al jugador
@export var kill_range: float = 2.0  # Rango en el que el enemigo mata al jugador

var patrol_target: Vector3  # Posición a la que se moverá el enemigo durante la patrulla
var chasing_player = false

func _ready():
	# Obtener el nodo NavigationRegion3D
	var region = get_node(navigation_region) as NavigationRegion3D
	if region:
		patrol_target = get_random_point_in_region(region)  # Obtener un punto aleatorio para patrullar
		if $NavigationAgent3D:
			$NavigationAgent3D.target_position = patrol_target
		else:
			print("NavigationAgent3D no está disponible")
	else:
		print("NavigationRegion3D no encontrado en la ruta especificada")

func _process(delta):
	if detect_player():
		chasing_player = true
		if $NavigationAgent3D:
			$NavigationAgent3D.target_position = player.global_transform.origin
	else:
		chasing_player = false

	if chasing_player:
		if $NavigationAgent3D:
			$NavigationAgent3D.target_position = player.global_transform.origin
			if is_within_kill_range():
				print("Enemigo está dentro del rango de matar al jugador.")
				kill_player()
		else:
			print("NavigationAgent3D no está disponible para perseguir al jugador")
	else:
		patrol(delta)

	# Mover al enemigo hacia el objetivo usando move_and_slide()
	if $NavigationAgent3D:
		var next_position = $NavigationAgent3D.get_next_path_position()
		if next_position:
			var direction = (next_position - global_transform.origin).normalized()
			# Usa la propiedad 'velocity' de CharacterBody3D
			velocity = direction * patrol_speed
			move_and_slide()  # Llama a move_and_slide sin argumentos
		else:
			print("No se pudo obtener la próxima posición de la ruta")

func patrol(delta):
	if $NavigationAgent3D:
		if $NavigationAgent3D.is_navigation_finished():
			var region = get_node(navigation_region) as NavigationRegion3D
			if region:
				patrol_target = get_random_point_in_region(region)
				$NavigationAgent3D.target_position = patrol_target
			else:
				print("NavigationRegion3D no encontrado para patrullar")

func detect_player() -> bool:
	if player:
		var distance_to_player = global_transform.origin.distance_to(player.global_transform.origin)
		return distance_to_player <= detection_range
	else:
		print("Jugador no está asignado en detect_player")
		return false

func is_within_kill_range() -> bool:
	if player:
		var distance_to_player = global_transform.origin.distance_to(player.global_transform.origin)
		return distance_to_player <= kill_range
	else:
		print("Jugador no está asignado para verificar rango de muerte")
		return false

func get_random_point_in_region(region: NavigationRegion3D) -> Vector3:
	var collision_shape = get_node("/root/TestingWorld/Enemy/CharacterBody3D/Colision_de_enemigo") as CollisionShape3D

	if collision_shape:
		var shape = collision_shape.shape as BoxShape3D
		if shape:
			var extents = shape.extents
			var center = collision_shape.global_transform.origin
			var random_point = Vector3(
				randf_range(center.x - extents.x, center.x + extents.x),
				randf_range(center.y - extents.y, center.y + extents.y),
				randf_range(center.z - extents.z, center.z + extents.z)
			)
			return random_point
		else:
			print("CollisionShape3D no tiene una BoxShape3D asociada")
			return global_transform.origin
	else:
		print("CollisionShape3D no encontrado en la ruta especificada")
		return global_transform.origin

func kill_player():
	if player:
		# Cambiar a la pantalla de muerte
		get_tree().change_scene_to_file("res://Escenas/PantallaMuerte.tscn")  # Cambia esto por la ruta correcta de tu escena de muerte
		print("Jugador ha sido eliminado. Cambiando a la pantalla de muerte.")
	else:
		print("Jugador no está asignado para matar")
