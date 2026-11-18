# Origem: escrito com auxílio de IA (Claude Code, assistente da Anthropic).
# Colher suspeita (colheres de pau... ou seriam pás?): giram longe do chef o tempo todo, num anel fora do alcance da faca,
# e no sentido contrário dela, batendo em quem estiver no caminho.
extends Node2D

const NOME := "Colher suspeita"

@export var cena_colher: PackedScene

var nivel := 1
# Evoluída, vira a Batucada: mais colheres, e cada pancada empurra as panelas.
var evoluida := false
var quantidade := 2
# A faca alcança no máximo 44 px (raio 40 + a ponta); as colheres giram além disso.
var raio := 56.0
var velocidade_giro := 3.0
var dano := 1
var angulo := 0.0


func _ready() -> void:
	montar()


# Cria as colheres de novo sempre que a quantidade ou o dano mudam.
func montar() -> void:
	for colher in get_children():
		colher.queue_free()
	for i in quantidade:
		var colher := cena_colher.instantiate()
		colher.dano = dano
		colher.batucada = evoluida
		add_child(colher)


func _process(delta: float) -> void:
	angulo -= velocidade_giro * delta
	var colheres := get_children().filter(func(c: Node) -> bool: return not c.is_queued_for_deletion())
	for i in colheres.size():
		var a := angulo + TAU * i / colheres.size()
		colheres[i].position = Vector2.from_angle(a) * raio
		colheres[i].rotation = a + PI / 2.0


func subir_nivel() -> void:
	nivel += 1
	# Três níveis: o 3 fica igual ao antigo nível 5 (4 colheres, 3 de dano, anel maior).
	match nivel:
		2:
			quantidade += 1
			raio += 10.0
			velocidade_giro += 1.0
			dano += 1
		3:
			quantidade += 1
			dano += 1
	montar()


# Batucada (Colher suspeita no nível 3): 6 colheres, e cada pancada solta
# uma mini-onda que empurra as panelas em volta.
func evoluir() -> void:
	evoluida = true
	quantidade = 6
	montar()
