# Origem: técnica do roteiro da Aula 09 (Prof. Ezéfferth), Partes 2.3 e 4.3 (o vila.gd) e ficha Defesa, aplicada à cozinha.
extends Node2D

@export var cena_inimigo: PackedScene

@onready var horda: Timer = $Horda
@onready var relogio: Timer = $Relogio
@onready var jogador := $Jogador
@onready var objeto := $Objeto
@onready var texto_vida: Label = $HUD/Vida
@onready var texto_tempo: Label = $HUD/Tempo
@onready var texto_caldeirao: Label = $HUD/Caldeirao


func _process(_delta: float) -> void:
	texto_vida.text = "Vida: %d" % jogador.vida
	texto_tempo.text = "Tempo: %d" % ceil(relogio.time_left)
	# Origem: IA (Claude) — placar dos toques no caldeirão, no formato dos placares das fichas.
	texto_caldeirao.text = "Caldeirão: %d / 5" % objeto.toques


func _on_horda_timeout() -> void:
	var inimigo := cena_inimigo.instantiate()
	inimigo.global_position = $Nascedouros.get_children().pick_random().global_position
	# Defesa: a panela vai atrás do caldeirão, e não do chef.
	inimigo.grupo_alvo = "objeto"
	add_child(inimigo)

	# A horda aperta: cada panela chega um pouco mais cedo que a anterior.
	horda.wait_time = max(0.5, horda.wait_time * 0.95)


func _on_relogio_timeout() -> void:
	vencer()


# No tipo Defesa, derrubar panela não conta ponto: o ataque só protege o caldeirão.
func inimigo_morreu(_inimigo: Node2D) -> void:
	pass


# call_deferred: troca de cena só no fim do quadro, quando a física terminou.
func vencer() -> void:
	get_tree().change_scene_to_file.call_deferred("res://scenes/vitoria.tscn")


func perder() -> void:
	get_tree().change_scene_to_file.call_deferred("res://scenes/derrota.tscn")
