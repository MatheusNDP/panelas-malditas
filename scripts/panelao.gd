# Origem: escrito com auxílio de IA (Claude Code, assistente da Anthropic).
# O Panelão: a panela gigante do último minuto. É lenta e aguenta muitos golpes,
# e, quando chega ao caldeirão, fica batendo nele até alguém derrubá-la.
# Na máquina de estados do inimigo.gd ele nunca fica TRAVADA (é pesado demais), e
# o estado ATACANDO não tem volta: depois que encosta no caldeirão, só sai quebrado.
extends "res://scripts/inimigo.gd"

var vida_maxima := 0

@onready var pancada: Timer = $Pancada


func _ready() -> void:
	super()
	vida_maxima = vida


func proximo_estado() -> Estado:
	if estado == Estado.ATACANDO:
		return Estado.ATACANDO
	return super()


# O caldeirão chama esta função quando o Panelão encosta nele (as outras panelas somem na hora).
func encostou_no_caldeirao() -> void:
	if estado != Estado.ATACANDO:
		mudar_estado(Estado.ATACANDO)


# Atacando, o Timer Pancada bate no caldeirão a cada 1,5 s; a primeira pancada é na hora.
func entrar_no_estado(novo: Estado) -> void:
	if novo == Estado.ATACANDO:
		pancada.start()
		_on_pancada_timeout()


func _on_pancada_timeout() -> void:
	get_tree().get_first_node_in_group("objeto").levar_toque()
	# Uma "cabeçada": o desenho pula para cima e volta.
	var cabecada := create_tween()
	cabecada.tween_property(sprite, "offset", Vector2(0, -11), 0.08)
	cabecada.tween_property(sprite, "offset", Vector2(0, -6), 0.12)
