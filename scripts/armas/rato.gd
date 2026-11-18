# Origem: escrito com auxílio de IA (Claude Code, assistente da Anthropic).
# Um ratinho do Ratatui. Sem panela por perto, ele fica em volta do chef.
# Com panela, corre até ela, gruda do lado e morde até ela quebrar; enquanto
# morde, a panela fica travada no lugar (o Panelão é pesado demais para travar).
# O rato é top_level: anda pelo mundo sozinho, e não junto com o chef.
extends Node2D

# Na Ninhada os ratos correm mais (a arma muda este valor).
var velocidade := 130.0
# Se a panela fugir para longe assim do chef, o rato larga e volta.
const COLEIRA := 160.0

var dano := 1
var intervalo := 0.8
# A posição do rato na roda em volta do chef (0, 1, 2...).
var lugar := 0
var alvo: Node2D = null
var espera := 0.0
# Relógio da animação de andar (começa sorteado para os ratos não andarem iguais).
var tempo := randf()

@onready var sprite: Sprite2D = $Sprite2D


func _physics_process(delta: float) -> void:
	var dono := get_parent() as Node2D
	if alvo != null and (not is_instance_valid(alvo) or alvo.vida <= 0 \
			or alvo.global_position.distance_to(dono.global_position) > COLEIRA):
		alvo = null
	if alvo == null:
		alvo = dono.escolher_alvo(self)
		espera = 0.0

	if alvo == null:
		# Cada rato fica num ponto da roda em volta do chef, um pouco abaixo dele.
		var roda := Vector2.from_angle(TAU * lugar / dono.get_child_count() + PI / 2.0) * Vector2(16, 8)
		andar_ate(dono.global_position + Vector2(0, 6) + roda, delta)
		return

	# Fica do lado da panela, na altura dos pés dela (a colisão fica 5 px abaixo do
	# centro), com o focinho encostando nela. Ratos na mesma panela ficam um mais
	# acima e outro mais abaixo, para não se esconderem um atrás do outro.
	var lado := 1.0 if global_position.x >= alvo.global_position.x else -1.0
	var boca: Vector2 = alvo.global_position + Vector2(lado * 13.0, 6.0 + (lugar % 3 - 1) * 5.0)
	if global_position.distance_to(boca) > 4.0:
		andar_ate(boca, delta)
		return

	global_position = boca
	sprite.flip_h = lado > 0.0
	sprite.frame = 0
	alvo.mordida = 0.15
	espera -= delta
	# Mordendo, o rato treme de um lado para o outro.
	sprite.position = Vector2(randf_range(-0.6, 0.6), 0)
	if espera <= 0.0:
		espera = intervalo
		alvo.levar_golpe(dano)


func andar_ate(ponto: Vector2, delta: float) -> void:
	var passo := velocidade * delta
	var longe := global_position.distance_to(ponto)
	sprite.position = Vector2.ZERO
	# Parado, o rato senta (quadro 0 do rato.png).
	if longe < 1.0:
		sprite.frame = 0
		return
	if abs(ponto.x - global_position.x) > 0.5:
		sprite.flip_h = ponto.x < global_position.x
	global_position = global_position.move_toward(ponto, passo)
	# Andando, ele fica de quatro e troca entre os quadros 1 e 2 (as patas alternam
	# e o rabo balança), 10 vezes por segundo.
	tempo += delta
	sprite.frame = 1 + int(tempo * 10.0) % 2
