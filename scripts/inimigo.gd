# Origem: técnica dos roteiros da Aula 09 (Parte 1.3, fichas Abate e Defesa) e da Aula 10 (Partes 1.4 e 2.4, a rota mais barata e o inimigo que aguenta mais), Prof. Ezéfferth, aplicada à panela.
extends CharacterBody2D

@export var velocidade: float = 40.0
@export var grupo_alvo: String = "player"
@export var vida: int = 1
# Quanto XP o chef ganha ao derrubar esta panela.
@export var xp: int = 1
# A cor dos cacos que voam quando a panela quebra.
@export var cor_cacos: Color = Color(0.77, 0.41, 0.27)

var tempo := 0.0

@onready var agente: NavigationAgent2D = $NavigationAgent2D
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	# A panela surge com um "pop": cresce de zero até o tamanho normal.
	sprite.scale = Vector2.ZERO
	create_tween().tween_property(sprite, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


# Andando, a panela vai dando pulinhos.
func _process(delta: float) -> void:
	if velocity.length() > 1.0:
		tempo += delta
		sprite.position.y = -abs(sin(tempo * 12.0)) * 2.0
	else:
		sprite.position.y = 0.0


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


func levar_golpe(dano: int = 1) -> void:
	vida -= dano
	if vida <= 0:
		get_tree().current_scene.inimigo_morreu(self)
		get_tree().current_scene.soltar_particulas(global_position, cor_cacos)
		queue_free()
		return

	# Ainda tem vida: a panela pisca branca para mostrar que o golpe pegou.
	sprite.modulate = Color(4, 4, 4)
	create_tween().tween_property(sprite, "modulate", Color.WHITE, 0.15)
