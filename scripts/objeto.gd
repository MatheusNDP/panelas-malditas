# Origem: ficha Defesa da folha da Aula 09 (Prof. Ezéfferth), aplicada ao caldeirão.
extends Area2D

var toques := 0


func _on_body_entered(inimigo: Node2D) -> void:
	inimigo.queue_free()
	toques += 1
	if toques >= 5:
		get_tree().current_scene.perder()
