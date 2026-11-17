# Garfos: de tempos em tempos o chef arremessa garfos nas panelas mais perto.
# O garfo voa reto e atravessa panelas até gastar a força.
extends Node2D

const NOME := "Garfos"

@export var cena_garfo: PackedScene

var nivel := 1
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
	for i in quantidade:
		var alvo: Node2D = alvos[min(i, alvos.size() - 1)]
		var garfo := cena_garfo.instantiate()
		garfo.global_position = global_position
		# Mira nos pés da panela (a colisão dela fica 5 px abaixo do centro).
		garfo.direcao = global_position.direction_to(alvo.global_position + Vector2(0, 5)).rotated(randf_range(-0.03, 0.03))
		garfo.dano = dano
		garfo.atravessa = atravessa
		get_tree().current_scene.add_child(garfo)
	Som.tocar("faca", -12.0)


func subir_nivel() -> void:
	nivel += 1
	match nivel:
		2: quantidade += 1
		3: atravessa += 1
		4: dano += 1
		5:
			quantidade += 1
			recarga = 0.8
