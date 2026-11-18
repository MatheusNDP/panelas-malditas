# Colheres de pau: giram longe do chef o tempo todo, num anel fora do alcance da faca,
# e no sentido contrário dela, batendo em quem estiver no caminho.
extends Node2D

const NOME := "Colheres de pau"

@export var cena_colher: PackedScene

var nivel := 1
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
	match nivel:
		2: quantidade += 1
		3:
			raio += 10.0
			velocidade_giro += 1.0
		4: dano += 1
		5:
			quantidade += 1
			dano += 1
	montar()
