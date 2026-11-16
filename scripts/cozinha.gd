# Origem: técnica dos roteiros da Aula 09 (Partes 2.3 e 4.3, o vila.gd, e ficha Defesa) e da Aula 10 (Parte 2.5, os abates), Prof. Ezéfferth, aplicada à cozinha.
extends Node2D

@export var cena_inimigo: PackedScene
@export var cena_frigideira: PackedScene
@export var cena_pressao: PackedScene
@export var cena_brava: PackedScene

var abates := 0
var fase_anunciada := 1

@onready var horda: Timer = $Horda
@onready var relogio: Timer = $Relogio
@onready var jogador := $Jogador
@onready var objeto := $Objeto
@onready var texto_vida: Label = $HUD/Vida
@onready var texto_tempo: Label = $HUD/Tempo
@onready var texto_caldeirao: Label = $HUD/Caldeirao
@onready var texto_fase: Label = $HUD/Fase


func _process(_delta: float) -> void:
	texto_vida.text = "Vida: %d   Abates: %d" % [jogador.vida, abates]
	texto_tempo.text = "Fase %d   Tempo: %d" % [fase(), ceil(relogio.time_left)]
	texto_caldeirao.text = "Caldeirão: %d / 5" % objeto.toques

	if fase() > fase_anunciada:
		fase_anunciada = fase()
		anunciar_fase()


# Os 3 minutos têm três fases de 1 minuto: a cada uma, mais lugares
# de onde as panelas saem e tipos mais difíceis no sorteio.
func fase() -> int:
	var passado := relogio.wait_time - relogio.time_left
	if passado < 60:
		return 1
	if passado < 120:
		return 2
	return 3


func anunciar_fase() -> void:
	if fase_anunciada == 2:
		texto_fase.text = "Fase 2: os fogões e as pias acordaram!"
	else:
		texto_fase.text = "Fase 3: chegaram a pressão e a brava!"
	texto_fase.visible = true
	await get_tree().create_timer(2.5).timeout
	texto_fase.visible = false


func _on_horda_timeout() -> void:
	# A horda aperta: cada panela chega um pouco mais cedo que a anterior.
	horda.wait_time = max(0.5, horda.wait_time * 0.95)

	var nascedouros := $Nascedouros.get_children()
	# Na fase 1 só as portas soltam panelas; os fogões e as pias acordam na fase 2.
	if fase() == 1:
		nascedouros = nascedouros.filter(func(n: Node) -> bool: return not n.has_node("Aviso"))
	var nascedouro: Node2D = nascedouros.pick_random()
	# Pelas portas a panela entra na hora. Dos fogões e das pias ela pula,
	# mas antes o aparelho pisca em vermelho por 1 s para dar tempo de chegar lá.
	if nascedouro.has_node("Aviso"):
		await piscar(nascedouro.get_node("Aviso"))
	soltar_panela(nascedouro.global_position)


func soltar_panela(posicao: Vector2) -> void:
	var inimigo := sortear_panela().instantiate()
	inimigo.global_position = posicao
	add_child(inimigo)


# Cada tipo de panela já sabe na própria cena quem persegue: as panelas comuns,
# a frigideira e a de pressão vão atrás do caldeirão; a brava vai atrás do chef.
# Fase 1: só comuns. Fase 2: entram as frigideiras. Fase 3: a pressão e a brava.
func sortear_panela() -> PackedScene:
	var sorteio := randf()
	if fase() == 1:
		return cena_inimigo
	if fase() == 2:
		if sorteio < 0.25:
			return cena_frigideira
		return cena_inimigo
	if sorteio < 0.2:
		return cena_frigideira
	if sorteio < 0.35:
		return cena_pressao
	if sorteio < 0.5:
		return cena_brava
	return cena_inimigo


# Cada aviso é uma cópia do Aviso do nascedouro: assim duas panelas
# saindo do mesmo fogão em seguida não apagam o aviso uma da outra.
func piscar(modelo: ColorRect) -> void:
	var aviso := modelo.duplicate() as ColorRect
	aviso.visible = true
	modelo.get_parent().add_child(aviso)
	var pisca := create_tween().set_loops(4)
	pisca.tween_property(aviso, "modulate:a", 0.2, 0.125)
	pisca.tween_property(aviso, "modulate:a", 1.0, 0.125)
	await pisca.finished
	aviso.queue_free()


func _on_relogio_timeout() -> void:
	vencer()


# No tipo Defesa os abates só aparecem no placar: quem decide a vitória é o relógio.
func inimigo_morreu(_inimigo: Node2D) -> void:
	abates += 1


# call_deferred: troca de cena só no fim do quadro, quando a física terminou.
func vencer() -> void:
	get_tree().change_scene_to_file.call_deferred("res://scenes/vitoria.tscn")


func perder() -> void:
	get_tree().change_scene_to_file.call_deferred("res://scenes/derrota.tscn")
