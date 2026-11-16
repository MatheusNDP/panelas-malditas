# Origem: ficha Defesa da folha da Aula 09 (Prof. Ezéfferth), aplicada ao caldeirão.
extends Area2D

var toques := 0


func _on_body_entered(inimigo: Node2D) -> void:
	# A panela brava só passa por cima: ela quer o chef, não a sopa.
	if inimigo.grupo_alvo != "objeto":
		return

	inimigo.queue_free()
	toques += 1
	if toques >= 5:
		get_tree().current_scene.perder()
