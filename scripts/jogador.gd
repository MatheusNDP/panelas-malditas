# Origem: técnica dos roteiros da Aula 08 (Parte 3.5), da Aula 09 (Parte 3.2) e da Aula 10 (Parte 2.3, o ataque), Prof. Ezéfferth, aplicada ao chef.
extends CharacterBody2D

@export var velocidade: float = 70.0
@export var vida: int = 3

var invencivel := false
var pode_atacar := true

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var ataque: Area2D = $Ataque
@onready var faca: Sprite2D = $Ataque/Faca


func _process(_delta: float) -> void:
	# Tem panela encostando em mim?
	if not invencivel and hurtbox.has_overlapping_bodies():
		levar_dano()

	if pode_atacar and Input.is_action_just_pressed("atacar"):
		atacar()


func _physics_process(_delta: float) -> void:
	var direcao := Input.get_vector("left", "right", "up", "down")
	velocity = direcao * velocidade
	move_and_slide()

	if direcao == Vector2.ZERO:
		anim.stop()
		return

	if abs(direcao.x) > abs(direcao.y):
		if direcao.x > 0:
			anim.play("direita")
		else:
			anim.play("esquerda")
	else:
		if direcao.y > 0:
			anim.play("baixo")
		else:
			anim.play("cima")


func levar_dano() -> void:
	vida -= 1
	if vida <= 0:
		get_tree().current_scene.perder()
		return

	# Um segundo de invencibilidade, meio transparente.
	invencivel = true
	modulate.a = 0.4
	await get_tree().create_timer(1.0).timeout
	modulate.a = 1.0
	invencivel = false


func atacar() -> void:
	# Acerta toda panela que estiver dentro do círculo neste quadro.
	for inimigo in ataque.get_overlapping_bodies():
		inimigo.levar_golpe()

	# A faca dá uma volta inteira no chef em 0,2 s; o próximo golpe só sai 0,4 s depois deste.
	pode_atacar = false
	faca.rotation = 0.0
	faca.visible = true
	var volta := create_tween()
	volta.tween_property(faca, "rotation", TAU, 0.2)
	await volta.finished
	faca.visible = false
	await get_tree().create_timer(0.2).timeout
	pode_atacar = true
