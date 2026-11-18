# Origem: técnica do roteiro da Aula 09 (Prof. Ezéfferth), Parte 4.1, com o resumo da partida; escrito com auxílio de IA (Claude Code, assistente da Anthropic).
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
		# Perdeu na hora extra: o serviço já estava salvo, então o título comemora.
		if Partida.hora_extra > 0.0:
			titulo.text = "Fim da hora extra!"
			titulo.add_theme_color_override("font_color", Color(1, 0.85, 0.4))
			var extra := int(Partida.hora_extra)
			motivo.text = "O chef aguentou %d:%02d a mais." % [extra / 60, extra % 60]
		# Partida perdida não tem como continuar: o botão começa uma nova.
		$Botoes/Continuar.text = "Jogar de Novo"

	var segundos := int(Partida.tempo)
	resumo.text = "Panelas derrubadas: %d\nNível alcançado: %d\nTempo: %d:%02d" % [Partida.abates, Partida.nivel, segundos / 60, segundos % 60]
	if Partida.panelao_derrotado:
		resumo.text += "\nPanelão derrotado!"
	if Partida.novo_recorde:
		recorde.text = "Novo recorde!"
	else:
		recorde.text = "Recorde: %d abates" % Partida.recorde


# Os dois botões embaixo. Depois de vencer, a tela está por cima da cozinha pausada
# e "Continuar Jogando" segue a mesma partida (a hora extra). Depois de perder,
# o botão começa uma partida nova.
func _on_continuar_pressed() -> void:
	var cozinha := get_tree().current_scene
	if Partida.venceu and cozinha.has_method("continuar_hora_extra"):
		cozinha.continuar_hora_extra()
		get_parent().queue_free()
	else:
		get_tree().change_scene_to_file("res://scenes/cozinha.tscn")


func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/titulo.tscn")
