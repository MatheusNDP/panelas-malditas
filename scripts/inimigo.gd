# Origem: técnica do roteiro da Aula 09 (Prof. Ezéfferth), Parte 1.3, e fichas Abate e Defesa, aplicadas à panela.
extends CharacterBody2D

@export var velocidade: float = 40.0
@export var grupo_alvo: String = "player"
@export var vida: int = 1

@onready var agente: NavigationAgent2D = $NavigationAgent2D


func _physics_process(_delta: float) -> void:
	var alvo := get_tree().get_first_node_in_group(grupo_alvo) as Node2D
	if alvo == null:
		return

	# A panela não vai mais em linha reta: o agente acha um caminho pela cozinha
	# que contorna as bancadas, e ela anda até o próximo ponto desse caminho.
	agente.target_position = alvo.global_position
	velocity = global_position.direction_to(agente.get_next_path_position()) * velocidade
	move_and_slide()


func levar_golpe() -> void:
	vida -= 1
	if vida <= 0:
		get_tree().current_scene.inimigo_morreu(self)
		queue_free()
