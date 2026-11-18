# Panelaço: o chef bate uma tampa de panela e solta uma onda que sai para todos os lados
# ao mesmo tempo. A onda acerta cada panela uma vez e a empurra para trás.
extends Node2D

const NOME := "Panelaço"

var nivel := 1
# Evoluída, vira o Gongo: onda enorme e dourada que deixa as panelas tontas.
var evoluida := false
var raio_max := 60.0
var dano := 1
var recarga := 3.0
var espera := 1.0
# Tamanho da onda agora; 0 quando não tem onda saindo.
var raio := 0.0
var acertadas := []


func _process(delta: float) -> void:
	espera -= delta
	if espera <= 0.0 and raio == 0.0:
		bater()
	if raio == 0.0:
		return

	# A onda cresce até o raio máximo em 0,4 s.
	raio += raio_max / 0.4 * delta
	for panela in get_tree().get_nodes_in_group("inimigo"):
		if panela in acertadas or global_position.distance_to(panela.global_position) > raio:
			continue
		acertadas.append(panela)
		panela.empurrar(global_position.direction_to(panela.global_position), 170.0)
		if evoluida:
			panela.tonta = 1.0
		panela.levar_golpe(dano)
	if raio >= raio_max:
		raio = 0.0
	queue_redraw()


func bater() -> void:
	espera = recarga
	raio = 1.0
	acertadas.clear()
	Som.tocar("panelaco", -6.0)


# A onda é desenhada na hora: dois anéis que vão sumindo conforme crescem.
func _draw() -> void:
	if raio == 0.0:
		return
	var forca := 1.0 - raio / raio_max
	# O Gongo desenha a onda dourada e mais grossa.
	var fora := Color(1, 0.85, 0.3) if evoluida else Color(1, 0.96, 0.75)
	var dentro := Color(1, 0.6, 0.15) if evoluida else Color(1, 0.75, 0.35)
	var grossura := 5.0 if evoluida else 3.0
	draw_arc(Vector2.ZERO, raio, 0.0, TAU, 64, Color(fora, 0.85 * forca), grossura)
	draw_arc(Vector2.ZERO, max(1.0, raio - 5.0), 0.0, TAU, 64, Color(dentro, 0.45 * forca), grossura - 1.0)


func subir_nivel() -> void:
	nivel += 1
	# Três níveis: o 3 fica igual ao antigo nível 5 (95 px, 3 de dano, a cada 2,2 s).
	match nivel:
		2:
			raio_max += 15.0
			dano += 1
		3:
			raio_max += 20.0
			dano += 1
			recarga = 2.2


# Gongo (Panelaço no nível 3): onda de 120 px a cada 2 s, 4 de dano,
# e as panelas atingidas ficam tontas, paradas, por 1 s.
func evoluir() -> void:
	evoluida = true
	raio_max = 120.0
	dano = 4
	recarga = 2.0
