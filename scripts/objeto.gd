# Origem: ficha Defesa da folha da Aula 09 (Prof. Ezéfferth), aplicada ao caldeirão.
extends Area2D

var toques := 0
# Quantos toques o caldeirão aguenta; a melhoria "tampa no caldeirão" aumenta.
var limite := 5


func _on_body_entered(inimigo: Node2D) -> void:
	# A panela brava só passa por cima: ela quer o chef, não a sopa.
	if inimigo.grupo_alvo != "objeto":
		return

	inimigo.queue_free()
	levar_toque()


# Um toque vem de uma panela que encostou ou do vapor da chaleira.
func levar_toque() -> void:
	toques += 1
	# O caldeirão pisca vermelho, a sopa espirra e a tela treme.
	$Sprite2D.modulate = Color(2.5, 0.6, 0.5)
	create_tween().tween_property($Sprite2D, "modulate", Color.WHITE, 0.3)
	get_tree().current_scene.soltar_particulas(global_position, Color(0.95, 0.55, 0.2))
	get_tree().current_scene.tremer(4.0)
	if toques >= limite:
		get_tree().current_scene.perder()
