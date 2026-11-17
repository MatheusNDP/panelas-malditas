# Uma colher de pau girando: bate em toda panela que ela encostar.
extends Area2D

var dano := 1


func _on_body_entered(corpo: Node2D) -> void:
	corpo.levar_golpe(dano)
