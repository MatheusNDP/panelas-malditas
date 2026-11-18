# Origem: escrito com auxílio de IA (Claude Code, assistente da Anthropic).
# Uma colher de pau girando: bate em toda panela que ela encostar.
extends Area2D

var dano := 1
# Na Batucada, cada pancada também solta uma mini-onda que empurra quem está perto.
var batucada := false


# Acerta a caixa Corpo da panela (do tamanho do desenho).
func _on_area_entered(corpo: Area2D) -> void:
	corpo.get_parent().levar_golpe(dano)
	if batucada:
		bater_tambor()


func bater_tambor() -> void:
	for panela in get_tree().get_nodes_in_group("inimigo"):
		if global_position.distance_to(panela.global_position) < 32.0:
			panela.empurrar(global_position.direction_to(panela.global_position), 150.0)
	get_tree().current_scene.soltar_particulas(global_position, Color(1, 0.85, 0.4))
	Som.tocar("panelaco", -16.0)
