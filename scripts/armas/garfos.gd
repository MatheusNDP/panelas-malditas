# Talheres: de tempos em tempos o chef arremessa talheres nas panelas mais perto;
# cada um sai sorteado, uma faca ou um garfo (quem sorteia é o próprio garfo.gd).
# O garfo voa reto e atravessa panelas até gastar a força.
extends Node2D

const NOME := "Talheres"

@export var cena_garfo: PackedScene

var nivel := 1
# Evoluída, vira o Faqueiro: talheres para todos os lados de uma vez.
var evoluida := false
# Ângulo da rajada do Faqueiro; gira um pouco a cada rajada.
var giro := 0.0
var quantidade := 1
var dano := 1
var atravessa := 1
var recarga := 1.2
var espera := 0.5
var alcance := 220.0


func _process(delta: float) -> void:
	espera -= delta
	if espera > 0.0:
		return

	# As panelas mais perto primeiro; longe demais, o chef nem arremessa.
	var alvos := get_tree().get_nodes_in_group("inimigo").filter(func(p: Node2D) -> bool:
		return global_position.distance_to(p.global_position) <= alcance)
	if alvos.is_empty():
		return
	alvos.sort_custom(func(a: Node2D, b: Node2D) -> bool:
		return global_position.distance_squared_to(a.global_position) < global_position.distance_squared_to(b.global_position))

	espera = recarga
	if evoluida:
		# Faqueiro: 8 talheres em roda, e a roda gira um pouco a cada rajada.
		giro += 0.4
		for i in 8:
			lancar(Vector2.from_angle(giro + TAU * i / 8.0))
	else:
		for i in quantidade:
			var alvo: Node2D = alvos[min(i, alvos.size() - 1)]
			# Mira nos pés da panela (a colisão dela fica 5 px abaixo do centro).
			lancar(global_position.direction_to(alvo.global_position + Vector2(0, 5)).rotated(randf_range(-0.03, 0.03)))
	Som.tocar("faca", -12.0)


func lancar(direcao: Vector2) -> void:
	var garfo := cena_garfo.instantiate()
	garfo.global_position = global_position
	garfo.direcao = direcao
	garfo.dano = dano
	garfo.atravessa = atravessa
	get_tree().current_scene.add_child(garfo)


func subir_nivel() -> void:
	nivel += 1
	# Três níveis: o 3 fica igual ao antigo nível 5 (3 talheres, 2 de dano, atravessam 2).
	match nivel:
		2:
			quantidade += 1
			atravessa += 1
		3:
			quantidade += 1
			dano += 1
			recarga = 0.8


# Faqueiro (Talheres no nível 3): 8 talheres para todos os lados a cada 1 s,
# 3 de dano, e cada um atravessa 4 panelas.
func evoluir() -> void:
	evoluida = true
	recarga = 1.0
	dano = 3
	atravessa = 4
