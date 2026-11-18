# Origem: escrito com auxílio de IA (Claude Code, assistente da Anthropic).
# A chaleira não encosta no caldeirão: ela para a uma distância dele e cospe vapor.
# Quem fica parado no centro perde toques, então o chef precisa ir até ela.
# Ela usa a máquina de estados do inimigo.gd e acrescenta o estado ATACANDO:
#   PERSEGUINDO -> ATACANDO quando chega a distancia_tiro do caldeirão
#   ATACANDO -> PERSEGUINDO se for empurrada para longe
#   ATACANDO ou PERSEGUINDO -> TRAVADA se um rato morder ou ficar tonta
extends "res://scripts/inimigo.gd"

@export var distancia_tiro: float = 80.0
@export var cena_vapor: PackedScene

var apitou := false

@onready var cuspe: Timer = $Cuspe


func proximo_estado() -> Estado:
	match estado:
		Estado.PERSEGUINDO:
			if presa():
				return Estado.TRAVADA
			if perto_do_alvo():
				return Estado.ATACANDO
		Estado.ATACANDO:
			if presa():
				return Estado.TRAVADA
			if not perto_do_alvo():
				return Estado.PERSEGUINDO
	return super()


# Atacando, o Timer Cuspe solta um vapor a cada 3 s; fora desse estado ele fica parado.
func entrar_no_estado(novo: Estado) -> void:
	if novo == Estado.ATACANDO:
		cuspe.start()


func sair_do_estado(antigo: Estado) -> void:
	if antigo == Estado.ATACANDO:
		cuspe.stop()
		apitou = false


func perto_do_alvo() -> bool:
	var alvo := get_tree().get_first_node_in_group(grupo_alvo) as Node2D
	return alvo != null and global_position.distance_to(alvo.global_position) <= distancia_tiro


# Meio segundo antes de cuspir, a chaleira apita: fica clara e treme.
func _process(delta: float) -> void:
	super(delta)
	if estado == Estado.ATACANDO and cuspe.time_left < 0.5:
		if not apitou:
			apitou = true
			Som.tocar("apito", -8.0)
		sprite.self_modulate = Color(1.6, 1.6, 1.6)
		sprite.offset = Vector2(randf_range(-1, 1), randf_range(-1, 1))
	else:
		sprite.self_modulate = Color.WHITE
		sprite.offset = Vector2.ZERO


func _on_cuspe_timeout() -> void:
	apitou = false
	var alvo := get_tree().get_first_node_in_group(grupo_alvo) as Node2D
	if alvo == null:
		return
	var vapor := cena_vapor.instantiate()
	vapor.global_position = global_position
	vapor.destino = alvo.global_position
	get_tree().current_scene.add_child(vapor)
