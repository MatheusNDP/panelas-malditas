# Pote de mel: o chef joga uma poça de mel grudento onde há panelas por perto.
# Quem pisa na poça fica preso, anda pela metade e se desgasta a cada meio segundo.
extends Node2D

const NOME := "Pote de mel"

@export var cena_poca: PackedScene

var nivel := 1
var raio := 18.0
var dano := 1
var duracao := 3.0
var recarga := 4.0
var espera := 1.0


func _process(delta: float) -> void:
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
	var poca := cena_poca.instantiate()
	poca.global_position = lugar
	poca.raio = raio
	poca.dano = dano
	poca.duracao = duracao
	get_tree().current_scene.add_child(poca)
	Som.tocar("mel", -6.0)


func subir_nivel() -> void:
	nivel += 1
	match nivel:
		2: raio += 6.0
		3: duracao += 1.5
		4: dano += 1
		5:
			raio += 6.0
			recarga = 2.8
