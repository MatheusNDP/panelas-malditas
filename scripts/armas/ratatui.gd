# Origem: escrito com auxílio de IA (Claude Code, assistente da Anthropic).
# Ratatui: ratinhos de estimação que andam com o chef. Quando tem panela perto,
# cada rato corre até uma, morde e segura a panela no lugar até ela quebrar.
# Cada nível traz mais um rato e mordidas mais rápidas (1, 2 e 3 ratos;
# no nível 3 cada um morde a cada 0,4 s). Evoluída, a Ninhada tem 4. A mordida tira sempre 1: a vida das panelas é
# um número inteiro, então o dano sobe pela pressa, não pela força.
extends Node2D

const NOME := "Ratatui"
# Até onde, a partir do chef, os ratos enxergam panela para atacar.
const ALCANCE := 90.0

@export var cena_rato: PackedScene

var nivel := 1
# Evoluída, vira a Ninhada: 4 ratos mais rápidos.
var evoluida := false
var quantidade := 1
var dano := 1
# Segundos entre uma mordida e a próxima.
var intervalo := 0.8
# Velocidade dos ratos correndo.
var velocidade := 130.0


func _ready() -> void:
	montar()


# Põe ratos novos até chegar na quantidade e passa o dano e o intervalo para todos.
func montar() -> void:
	while get_child_count() < quantidade:
		var rato := cena_rato.instantiate()
		rato.global_position = global_position
		add_child(rato)
	for i in get_child_count():
		var rato := get_child(i)
		rato.lugar = i
		rato.dano = dano
		rato.intervalo = intervalo
		rato.velocidade = velocidade


# O rato pede uma panela: a mais perto do chef que nenhum outro rato está mordendo.
# Se todas as panelas perto já têm rato, ele ajuda na mais perto.
func escolher_alvo(quem: Node2D) -> Node2D:
	var melhor: Node2D = null
	var menor := INF
	for panela in get_tree().get_nodes_in_group("inimigo"):
		if panela.vida <= 0:
			continue
		var distancia := global_position.distance_to(panela.global_position)
		if distancia > ALCANCE:
			continue
		for rato in get_children():
			if rato != quem and rato.alvo == panela:
				distancia += 1000.0
				break
		if distancia < menor:
			menor = distancia
			melhor = panela
	return melhor


func subir_nivel() -> void:
	nivel += 1
	# Três níveis: 1, 2 e 3 ratos, mordendo cada vez mais rápido.
	match nivel:
		2:
			quantidade = 2
			intervalo = 0.6
		3:
			quantidade = 3
			intervalo = 0.4
	montar()


# Ninhada (Ratatui no nível 3): 4 ratos que mordem a cada 0,3 s e correm mais.
# (Com 8 ratos ela ficava forte demais: travava 8 panelas ao mesmo tempo.)
func evoluir() -> void:
	evoluida = true
	quantidade = 4
	intervalo = 0.3
	velocidade = 170.0
	montar()
