# Origem: técnica dos roteiros da Aula 09 (Parte 1.3, fichas Abate e Defesa) e da Aula 10 (Partes 1.4 e 2.4, a rota mais barata e o inimigo que aguenta mais), Prof. Ezéfferth, aplicada à panela.
extends CharacterBody2D

@export var velocidade: float = 40.0
@export var grupo_alvo: String = "player"
@export var vida: int = 1
# Quanto XP o chef ganha ao derrubar esta panela.
@export var xp: int = 1
# A cor dos cacos que voam quando a panela quebra.
@export var cor_cacos: Color = Color(0.77, 0.41, 0.27)
# Quanto mais pesada, menos o empurrão do Panelaço joga a panela para trás.
@export var peso: float = 1.0
# Chance (de 0 a 1) de soltar um power-up quando quebra.
@export var chance_power_up: float = 0.04

var tempo := 0.0
var empurrao := Vector2.ZERO
# Segundos que a panela ainda anda pela metade (pisou no azeite quente).
var lentidao := 0.0

@onready var agente: NavigationAgent2D = $NavigationAgent2D
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	# A panela surge com um "pop": cresce de zero até o tamanho dela.
	var tamanho := sprite.scale
	sprite.scale = Vector2.ZERO
	create_tween().tween_property(sprite, "scale", tamanho, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


# Andando, a panela vai dando pulinhos.
func _process(delta: float) -> void:
	if velocity.length() > 1.0:
		tempo += delta
		sprite.position.y = -abs(sin(tempo * 12.0)) * 2.0
	else:
		sprite.position.y = 0.0


func _physics_process(delta: float) -> void:
	# A panela não vai mais em linha reta: o agente acha um caminho pela cozinha
	# que contorna as bancadas, e ela anda até o próximo ponto desse caminho.
	var proximo := agente.get_next_path_position()
	var fator := 0.5 if lentidao > 0.0 else 1.0
	lentidao -= delta
	velocity = global_position.direction_to(proximo) * velocidade * fator + empurrao
	empurrao = empurrao.move_toward(Vector2.ZERO, 500.0 * delta)
	move_and_slide()


# O Panelaço joga a panela para trás; o empurrão vai diminuindo sozinho.
func empurrar(direcao: Vector2, forca: float) -> void:
	empurrao = direcao * forca / peso


# O caminho é recalculado 5 vezes por segundo (o Timer de 0,2 s), e não a cada quadro.
func _on_timer_timeout() -> void:
	var alvo := get_tree().get_first_node_in_group(grupo_alvo) as Node2D
	if alvo == null:
		return
	agente.target_position = alvo.global_position


func levar_golpe(dano: int = 1) -> void:
	# Duas armas podem acertar no mesmo quadro: a panela que já quebrou não quebra de novo.
	if vida <= 0:
		return
	vida -= dano
	if vida <= 0:
		get_tree().current_scene.inimigo_morreu(self)
		get_tree().current_scene.soltar_particulas(global_position, cor_cacos)
		Som.tocar("quebra", -2.0)
		queue_free()
		return

	# Ainda tem vida: a panela pisca branca para mostrar que o golpe pegou.
	Som.tocar("acerto", -3.0)
	# TWEEN_PAUSE_STOP: a piscada roda mesmo com a panela congelada (process_mode desligado)
	# e só para quando o jogo inteiro está pausado.
	sprite.modulate = Color(4, 4, 4)
	create_tween().set_pause_mode(Tween.TWEEN_PAUSE_STOP).tween_property(sprite, "modulate", Color.WHITE, 0.15)
