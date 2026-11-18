# Origem: escrito com auxílio de IA (Claude Code, assistente da Anthropic).
# O vapor da chaleira voa em linha reta até o caldeirão e tira um toque dele.
# Se o chef entrar na frente, o vapor se desfaz nele sem fazer mal.
extends Area2D

@export var velocidade: float = 70.0

var destino := Vector2.ZERO


func _physics_process(delta: float) -> void:
	global_position = global_position.move_toward(destino, velocidade * delta)
	rotation += 6.0 * delta
	if global_position.distance_to(destino) < 2.0:
		get_tree().get_first_node_in_group("objeto").levar_toque()
		queue_free()


func _on_body_entered(_body: Node2D) -> void:
	Som.tocar("chiado")
	queue_free()
