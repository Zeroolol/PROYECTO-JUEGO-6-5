extends StaticBody3D  # O el tipo de nodo que estés utilizando

@onready var dialog_label: Label = get_node("/root/TestingWorld/Dialogos/Panel/TextoDialogo")  # Ruta al Label de diálogo
@onready var mensaje_label: Label = get_node("/root/TestingWorld/Dialogos/MensajeMission")  # Ruta al Label de misión
@onready var jugador = get_node("/root/TestingWorld/Player")  # Referencia al jugador
@onready var audio_player: AudioStreamPlayer3D = get_node("/root/TestingWorld/Sounds/PhoneSound")  # Nodo para reproducir el sonido del teléfono
@onready var panel_static_body = get_node("/root/TestingWorld/PanelElectrico/PanelCuerpo/StaticBody3D")  # Nodo StaticBody3D del panel que contiene la propiedad panel_interacted

# Nodo Monster SA
@onready var monster_sa: Node3D = get_node("/root/TestingWorld/MonsterSA")  # Referencia al nodo MonsterSA

# Referencias a los AnimationPlayer en la escena TestingWorld
@onready var animation_player_1: AnimationPlayer = get_node("/root/TestingWorld/MonsterSA/CRIATURA_FEA (3)/AnimationPlayer")  # Cambia la ruta
@onready var animation_player_2: AnimationPlayer = get_node("/root/TestingWorld/MonsterSA/AnimationPlayer")  # Cambia la ruta

# Referencias a los sonidos que se reproducirán junto con las animaciones
@onready var sound_1: AudioStreamPlayer3D = get_node("/root/TestingWorld/Sounds/SFX1")  # Sonido 1
@onready var sound_2: AudioStreamPlayer3D = get_node("/root/TestingWorld/MonsterSA/MonsterFootsteps")  # Sonido 2

func _ready():
	# Hacer que Monster SA no sea visible al inicio
	monster_sa.visible = false

func _input(event):
	if event.is_action_pressed("Interact"):
		if is_in_range():
			interact(jugador)

# Comprueba si el jugador está lo suficientemente cerca del objeto
func is_in_range() -> bool:
	return position.distance_to(jugador.position) < 2.0  # Cambia 2.0 a la distancia deseada

# Función para interactuar con el teléfono
func interact(jugador):
	# Verificar si el jugador ya interactuó con el panel
	if panel_static_body.panel_interacted:
		# Si el jugador ya interactuó con el panel, reproducir sonido y animaciones
		print("Interacción con el teléfono después del panel, reproduciendo sonido y animaciones...")
		reproducir_sonido()
	else:
		# Si no ha interactuado con el panel, mostrar el diálogo y misión
		print("Interacción detectada con el jugador:", jugador)
		mostrar_dialogo("Lpm, no hay energía, necesito reconectarla")
		await get_tree().create_timer(3.0).timeout
		ocultar_dialogo()
		await mostrar_mensaje_final("BUSCA UNA FORMA DE RESTABLECER LA ELECTRICIDAD")

# Función para reproducir el sonido del teléfono
func reproducir_sonido():
	if audio_player:
		audio_player.play()  # Reproduce el sonido del teléfono
		# Conectar la señal "finished" del audio para ejecutar después las animaciones
		audio_player.connect("finished", Callable(self, "_on_sonido_finalizado"))  # Aquí se usa Callable

# Función que se ejecuta cuando termina el sonido
func _on_sonido_finalizado():
	print("El sonido ha terminado. Reproduciendo animaciones después de 3 segundos...")
	mostrar_dialogo("¿Qué fue eso? Tengo que salir de aquí ahora.")
	await get_tree().create_timer(3.0).timeout  # Espera 3 segundos antes de ocultar el diálogo
	ocultar_dialogo()

	reproducir_animaciones_y_sonidos()

# Función para reproducir ambas animaciones y los sonidos simultáneamente
func reproducir_animaciones_y_sonidos():
	print("Reproduciendo animaciones y sonidos simultáneamente...")
	
	# Hacer que Monster SA sea visible antes de reproducir las animaciones
	monster_sa.visible = true

	# Reproduce ambas animaciones
	if animation_player_1 and animation_player_2:
		animation_player_1.play("Patrullaje")  # Cambia con el nombre de la animación
		animation_player_2.play("AnimacionMonsterSA")  # Cambia con el nombre de la animación
		print("Animaciones reproducidas.")
		
		# Conectar la señal 'animation_finished' de animation_player_2 para ocultar Monster SA al terminar
		animation_player_2.connect("animation_finished", Callable(self, "_on_animation_player_2_finished"))

	# Reproduce los dos sonidos al mismo tiempo que las animaciones
	if sound_1 and sound_2:
		sound_1.play()  # Reproduce el sonido 1
		sound_2.play()  # Reproduce el sonido 2
		print("Sonidos reproducidos.")

# Función para cuando la animación de animation_player_2 termina
func _on_animation_player_2_finished(anim_name: String):
	# Verificar si la animación que terminó es la correcta
	if anim_name == "Secuencia1Mons":  # Cambia con el nombre correcto de la animación
		print("La animación de animation_player_2 ha terminado. Ocultando Monster SA...")
		monster_sa.visible = false  # Ocultar Monster SA

# Función para mostrar el mensaje final
func mostrar_mensaje_final(mensaje: String):
	mensaje_label.text = mensaje
	mensaje_label.visible = true
	await get_tree().create_timer(3.0).timeout
	mensaje_label.visible = false

# Función para mostrar el diálogo
func mostrar_dialogo(texto: String):
	dialog_label.text = texto
	dialog_label.get_parent().visible = true

# Función para ocultar el diálogo
func ocultar_dialogo():
	dialog_label.get_parent().visible = false
	dialog_label.text = ""
