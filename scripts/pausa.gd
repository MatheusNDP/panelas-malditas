# Pausa com Esc: o jogo para e aparecem as opções de continuar ou voltar ao início.
# Roda sempre (process_mode Always) para ouvir o Esc com o jogo parado ou não.
extends CanvasLayer


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if visible:
			continuar()
		# Com a tela de melhoria aberta o jogo já está pausado: aí o Esc não faz nada.
		elif not get_tree().paused:
			visible = true
			get_tree().paused = true
	elif visible:
		var tecla := event as InputEventKey
		if tecla and tecla.pressed and tecla.keycode == KEY_M:
			voltar_ao_inicio()


func continuar() -> void:
	visible = false
	get_tree().paused = false


func voltar_ao_inicio() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/titulo.tscn")
