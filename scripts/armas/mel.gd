# Pote de mel: o chef joga uma poça de mel grudento onde há panelas por perto.
# Quem pisa na poça fica preso, anda pela metade e se desgasta a cada meio segundo.
extends Node2D

const NOME := "Pote de mel"

@export var cena_poca: PackedScene

var nivel := 1
# Evoluída, vira o Rastro de Mel: o chef também deixa mel por onde anda.
var evoluida := false
var rastro := 0.0
var raio := 18.0
var dano := 1
var duracao := 3.0
var recarga := 4.0
var espera := 1.0


func _process(delta: float) -> void:
	# Rastro de Mel: andando, o chef pinga uma poça menor a cada 0,35 s.
	if evoluida:
		rastro -= delta
		var chef := get_parent().get_parent() as CharacterBody2D
		if rastro <= 0.0 and chef.velocity.length() > 5.0:
			rastro = 0.35
			soltar_poca(global_position + Vector2(0, 6), 16.0, 3.0)

	espera -= delta
	if espera > 0.0:
		return
	espera = recarga

	# Na panela mais perto (até 140 px); se não tiver nenhuma, aos pés do chef.
	var lugar := global_position
	var melhor := 140.0
	for panela in get_tree().get_nodes_in_group("inimigo"):
		var d := global_position.distance_to(panela.global_position)
		if d < melhor:
			melhor = d
			lugar = panela.global_position
	soltar_poca(lugar, raio, duracao)
	Som.tocar("mel", -6.0)


func soltar_poca(lugar: Vector2, tamanho: float, quanto_dura: float) -> void:
	var poca := cena_poca.instantiate()
	poca.global_position = lugar
	poca.raio = tamanho
	poca.dano = dano
	poca.duracao = quanto_dura
	get_tree().current_scene.add_child(poca)


func subir_nivel() -> void:
	nivel += 1
	# Três níveis: o 3 fica igual ao antigo nível 5 (poça de 30 px, 2 de dano, a cada 2,8 s).
	match nivel:
		2:
			raio += 6.0
			duracao += 1.5
		3:
			raio += 6.0
			dano += 1
			recarga = 2.8


# Rastro de Mel (Pote de mel no nível 3): continua jogando as poças de sempre,
# e o chef deixa um rastro de poças menores (16 px, 3 s) por onde anda.
func evoluir() -> void:
	evoluida = true
