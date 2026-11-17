# Origem: técnica do roteiro da Aula 09 (Prof. Ezéfferth), Parte 4.1, com o resumo da partida.
extends Control

@onready var titulo: Label = $Titulo
@onready var motivo: Label = $Motivo
@onready var resumo: Label = $Painel/Resumo
@onready var recorde: Label = $Recorde


func _ready() -> void:
	Som.parar_musica()
	if Partida.venceu:
		Som.tocar("vitoria", 0.0, false)
		titulo.text = "O serviço está salvo!"
		titulo.add_theme_color_override("font_color", Color(0.65, 0.92, 0.45))
		motivo.text = "A sopa aguentou os 3 minutos."
	else:
		Som.tocar("derrota", 0.0, false)
		titulo.add_theme_color_override("font_color", Color(1, 0.42, 0.35))
		if Partida.motivo == "chef":
			titulo.text = "O chef caiu!"
			motivo.text = "As panelas venceram o chef."
		else:
			titulo.text = "A sopa foi perdida!"
			motivo.text = "As panelas derrubaram o caldeirão."

	var segundos := int(Partida.tempo)
	resumo.text = "Panelas derrubadas: %d\nNível alcançado: %d\nTempo: %d:%02d" % [Partida.abates, Partida.nivel, segundos / 60, segundos % 60]
	if Partida.novo_recorde:
		recorde.text = "Novo recorde!"
	else:
		recorde.text = "Recorde: %d abates" % Partida.recorde


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/cozinha.tscn")
	elif Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/titulo.tscn")
