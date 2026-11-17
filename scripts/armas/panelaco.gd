# Panelaço: o chef bate uma tampa de panela e solta uma onda que sai para todos os lados
# ao mesmo tempo. A onda acerta cada panela uma vez e a empurra para trás.
extends Node2D

const NOME := "Panelaço"

var nivel := 1
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
	draw_arc(Vector2.ZERO, raio, 0.0, TAU, 48, Color(1, 0.96, 0.75, 0.85 * forca), 3.0)
	draw_arc(Vector2.ZERO, max(1.0, raio - 5.0), 0.0, TAU, 48, Color(1, 0.75, 0.35, 0.45 * forca), 2.0)


func subir_nivel() -> void:
	nivel += 1
	match nivel:
		2: raio_max += 15.0
		3: dano += 1
		4: recarga = 2.2
		5:
			raio_max += 20.0
			dano += 1
