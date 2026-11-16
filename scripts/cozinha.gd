# Origem: técnica dos roteiros da Aula 09 (Partes 2.3 e 4.3, o vila.gd, e ficha Defesa) e da Aula 10 (Parte 2.5, os abates), Prof. Ezéfferth, aplicada à cozinha.
extends Node2D

@export var cena_inimigo: PackedScene

var abates := 0

@onready var horda: Timer = $Horda
@onready var relogio: Timer = $Relogio
@onready var jogador := $Jogador
@onready var objeto := $Objeto
@onready var texto_vida: Label = $HUD/Vida
@onready var texto_tempo: Label = $HUD/Tempo
@onready var texto_caldeirao: Label = $HUD/Caldeirao


func _process(_delta: float) -> void:
	texto_vida.text = "Vida: %d   Abates: %d" % [jogador.vida, abates]
	texto_tempo.text = "Tempo: %d" % ceil(relogio.time_left)
	texto_caldeirao.text = "Caldeirão: %d / 5" % objeto.toques


func _on_horda_timeout() -> void:
	# A horda aperta: cada panela chega um pouco mais cedo que a anterior.
	horda.wait_time = max(0.5, horda.wait_time * 0.95)

	var nascedouro: Node2D = $Nascedouros.get_children().pick_random()
	# Pelas portas a panela entra na hora. Dos fogões e das pias ela pula,
	# mas antes o aparelho pisca em vermelho por 1 s para dar tempo de chegar lá.
	if nascedouro.has_node("Aviso"):
		await piscar(nascedouro.get_node("Aviso"))
	soltar_panela(nascedouro.global_position)


func soltar_panela(posicao: Vector2) -> void:
	var inimigo := cena_inimigo.instantiate()
	inimigo.global_position = posicao
	# Defesa: a panela vai atrás do caldeirão, e não do chef.
	inimigo.grupo_alvo = "objeto"
	add_child(inimigo)


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
