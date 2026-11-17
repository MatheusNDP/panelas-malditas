# Origem: técnica do roteiro da Aula 09 (Prof. Ezéfferth), Parte 4.1.
extends Control

# O som que toca quando a tela aparece: "vitoria" ou "derrota".
@export var som := "vitoria"


func _ready() -> void:
	Som.parar_musica()
	Som.tocar(som, 0.0, false)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/cozinha.tscn")
