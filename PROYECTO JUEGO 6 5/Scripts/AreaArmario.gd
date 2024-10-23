extends Area3D

# Señal que se emitirá cuando el jugador entre o salga del armario
signal player_entered(is_hiding)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):  # Asegúrate de que el jugador esté en el grupo "player"
		emit_signal("player_entered", true)  # Emitir señal indicando que el jugador se esconde

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		emit_signal("player_entered", false)  # Emitir señal indicando que el jugador salió del armario
