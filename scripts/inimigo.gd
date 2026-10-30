# Origem: técnica dos roteiros da Aula 09 (Parte 1.3, fichas Abate e Defesa) e da Aula 10 (Partes 1.4 e 2.4 e a rota mais barata), Prof. Ezéfferth, aplicada à panela.
extends CharacterBody2D

@export var velocidade: float = 40.0
@export var grupo_alvo: String = "player"
@export var vida: int = 1

@onready var agente: NavigationAgent2D = $NavigationAgent2D


func _physics_process(_delta: float) -> void:
	# A panela não vai mais em linha reta: o agente acha um caminho pela cozinha
	# que contorna as bancadas, e ela anda até o próximo ponto desse caminho.
	var proximo := agente.get_next_path_position()
	velocity = global_position.direction_to(proximo) * velocidade
	move_and_slide()


# O caminho é recalculado 5 vezes por segundo (o Timer de 0,2 s), e não a cada quadro.
func _on_timer_timeout() -> void:
	var alvo := get_tree().get_first_node_in_group(grupo_alvo) as Node2D
	if alvo == null:
		return
	agente.target_position = alvo.global_position


func levar_golpe() -> void:
	vida -= 1
	if vida <= 0:
		get_tree().current_scene.inimigo_morreu(self)
		queue_free()
