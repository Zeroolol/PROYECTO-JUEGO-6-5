extends StaticBody3D

@onready var dialog_label: Label = get_node("/root/TestingWorld/Dialogos/Panel/TextoDialogo")
@onready var mensaje_label: Label = get_node("/root/TestingWorld/Dialogos/MensajeMission")
@onready var jugador = get_node("/root/TestingWorld/Player")
@onready var audio_player: AudioStreamPlayer3D = get_node("/root/TestingWorld/Sounds/PhoneSound")
@onready var panel_static_body = get_node("/root/TestingWorld/PanelElectrico/PanelCuerpo/StaticBody3D")
@onready var monster_sa: Node3D = get_node("/root/TestingWorld/MonsterSA")
@onready var animation_player_1: AnimationPlayer = get_node("/root/TestingWorld/MonsterSA/CRIATURA_FEA (3)/AnimationPlayer")
@onready var animation_player_2: AnimationPlayer = get_node("/root/TestingWorld/MonsterSA/AnimationPlayer")
@onready var sound_1: AudioStreamPlayer3D = get_node("/root/TestingWorld/Sounds/SFX1")
@onready var sound_2: AudioStreamPlayer3D = get_node("/root/TestingWorld/MonsterSA/MonsterFootsteps")

func _ready():
	# Inicialmente el monstruo no es visible
	monster_sa.visible = false

func _input(event):
	if event.is_action_pressed("Interact"):
		if is_in_range():
			interact(jugador)

func is_in_range() -> bool:
	# Verifica si el jugador está lo suficientemente cerca
	return position.distance_to(jugador.position) < 2.0

func interact(jugador):
	if panel_static_body.panel_interacted:
		print("Interacción con el teléfono después del panel, reproduciendo sonido y animaciones...")
		reproducir_sonido()
	else:
		print("Interacción detectada con el jugador:", jugador)
		mostrar_dialogo("Lpm, no hay energía, necesito reconectarla")
		await get_tree().create_timer(3.0).timeout
		ocultar_dialogo()
		await mostrar_mensaje_final("BUSCA UNA FORMA DE RESTABLECER LA ELECTRICIDAD")

func reproducir_sonido():
	if audio_player:
		audio_player.play()
		audio_player.connect("finished", Callable(self, "_on_sonido_finalizado"))

func _on_sonido_finalizado():
	print("El sonido ha terminado. Reproduciendo animaciones...")
	mostrar_dialogo("¿Qué fue eso? Tengo que salir de aquí ahora.")
	await get_tree().create_timer(3.0).timeout
	ocultar_dialogo()
	reproducir_animaciones_y_sonidos()

func reproducir_animaciones_y_sonidos():
	print("Reproduciendo animaciones y sonidos...")
	monster_sa.visible = true  # Mostrar el monstruo antes de las animaciones

	if animation_player_1 and animation_player_2:
		animation_player_1.play("Patrullaje")
		animation_player_2.play("AnimacionMonsterSA")
		print("Animaciones reproducidas.")
		
		# Desconectar la señal si estaba conectada previamente, y conectar nuevamente
		animation_player_2.disconnect("animation_finished", Callable(self, "_on_animation_player_2_finished"))
		animation_player_2.connect("animation_finished", Callable(self, "_on_animation_player_2_finished"))

	if sound_1 and sound_2:
		sound_1.play()
		sound_2.play()
		print("Sonidos reproducidos.")

# Función cuando la animación de animation_player_2 termine
# Function when animation in animation_player_2 finishes
func _on_animation_player_2_finished(anim_name: String):
	print("Animación terminada: ", anim_name)
	if anim_name == "AnimacionMonsterSA":  # Ensure this matches your animation name
		print("La animación ha terminado. Ocultando Monster SA...")
		monster_sa.visible = false  # Hide the monster after the animation finishes


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
