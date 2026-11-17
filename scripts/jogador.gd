# Origem: técnica dos roteiros da Aula 08 (Parte 3.5), da Aula 09 (Parte 3.2) e da Aula 10 (Parte 2.3, o ataque), Prof. Ezéfferth, aplicada ao chef.
extends CharacterBody2D

@export var velocidade: float = 70.0
@export var vida: int = 3
# Tempo entre um giro da faca e o próximo; a melhoria "golpe mais rápido" diminui.
@export var recarga: float = 0.4

var invencivel := false
var pode_atacar := true
var dano := 1
var forma_ataque: CircleShape2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var ataque: Area2D = $Ataque
@onready var faca: Sprite2D = $Ataque/Faca
@onready var rastro: Sprite2D = $Ataque/Rastro


func _ready() -> void:
	# Uma cópia do círculo do ataque só deste chef: a melhoria "faca maior" muda o raio,
	# e sem a cópia o raio maior continuaria na partida seguinte.
	forma_ataque = $Ataque/CollisionShape2D.shape.duplicate()
	$Ataque/CollisionShape2D.shape = forma_ataque


func _process(_delta: float) -> void:
	# Tem panela encostando em mim?
	if not invencivel and hurtbox.has_overlapping_bodies():
		levar_dano()

	# O ataque é automático: a faca gira sozinha sempre que a recarga termina.
	if pode_atacar:
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
	Som.tocar("dano")
	get_tree().current_scene.tremer(3.0)
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
	var acertadas := ataque.get_overlapping_bodies()
	if not acertadas.is_empty():
		Som.tocar("faca", -4.0)
	for inimigo in acertadas:
		inimigo.levar_golpe(dano)

	# A faca dá uma volta inteira no chef (em 0,2 s, ou menos se a recarga for curta);
	# o próximo golpe só sai quando a recarga termina.
	pode_atacar = false
	var giro: float = min(0.2, recarga * 0.8)
	faca.rotation = 0.0
	faca.visible = true
	var volta := create_tween()
	volta.tween_property(faca, "rotation", TAU, giro)
	# O rastro: um anel claro que aparece com o giro e some aos poucos.
	rastro.visible = true
	rastro.modulate.a = 0.8
	create_tween().tween_property(rastro, "modulate:a", 0.0, giro * 1.5)
	await volta.finished
	faca.visible = false
	await get_tree().create_timer(recarga - giro, false).timeout
	pode_atacar = true


# Melhoria "faca maior": o círculo do golpe cresce e a faca cresce junto,
# com a ponta sempre 4 px além do raio (no começo, raio 24 e ponta em 28).
func aumentar_alcance(quanto: float) -> void:
	forma_ataque.radius += quanto
	faca.scale = Vector2.ONE * (forma_ataque.radius + 4.0) / 28.0
	rastro.scale = Vector2.ONE * (forma_ataque.radius + 4.0) / 32.0
