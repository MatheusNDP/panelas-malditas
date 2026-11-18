# Origem: técnica dos roteiros da Aula 08 (Parte 3.5), da Aula 09 (Parte 3.2) e da Aula 10 (Parte 2.3, o ataque), Prof. Ezéfferth, aplicada ao chef.
extends CharacterBody2D

@export var velocidade: float = 70.0
@export var vida: int = 3
# Tempo entre um giro da faca e o próximo; a melhoria "golpe mais rápido" diminui.
@export var recarga: float = 0.4
# Até onde as bolinhas de XP são puxadas (o power-up Ímã puxa todas, de qualquer distância).
@export var raio_ima: float = 64.0

var invencivel := false
var pode_atacar := true
var dano := 1
var forma_ataque: CircleShape2D
var vida_maxima := 0
# Segundos que ainda faltam do efeito da pimenta (chef mais rápido).
var pressa := 0.0
# As panelas que a faca já cortou na volta atual (para não acertar duas vezes a mesma).
var acertadas_no_giro: Array = []
# Cutelo do Chef (a evolução da faca): uma segunda lâmina do lado oposto, que também
# acerta cada panela uma vez por volta.
var cutelo := false
var faca2: Sprite2D = null
var acertadas_lamina2: Array = []

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var ataque: Area2D = $Ataque
@onready var faca: Sprite2D = $Ataque/Faca
@onready var rastro: Sprite2D = $Ataque/Rastro


func _ready() -> void:
	vida_maxima = vida
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


func _physics_process(delta: float) -> void:
	# Enquanto a faca gira, corta as panelas por onde a lâmina passa.
	if faca.visible:
		if faca2:
			faca2.rotation = faca.rotation + PI
		golpear_no_caminho()

	var direcao := Input.get_vector("left", "right", "up", "down")
	# Com a pimenta, o chef anda 60% mais rápido e fica avermelhado.
	pressa -= delta
	var acelerado := pressa > 0.0
	velocity = direcao * velocidade * (1.6 if acelerado else 1.0)
	anim.self_modulate = Color(1.3, 0.8, 0.7) if acelerado else Color.WHITE
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
		get_tree().current_scene.perder("chef")
		return

	# Um segundo de invencibilidade, meio transparente.
	invencivel = true
	modulate.a = 0.4
	await get_tree().create_timer(1.0).timeout
	modulate.a = 1.0
	invencivel = false


func atacar() -> void:
	# A faca dá uma volta inteira no chef (em 0,2 s, ou menos se a recarga for curta);
	# o próximo golpe só sai quando a recarga termina.
	pode_atacar = false
	acertadas_no_giro.clear()
	acertadas_lamina2.clear()
	var giro: float = min(0.2, recarga * 0.8)
	faca.rotation = 0.0
	faca.visible = true
	if faca2:
		faca2.rotation = PI
		faca2.visible = true
	var volta := create_tween()
	volta.tween_property(faca, "rotation", TAU, giro)
	# O rastro: um anel claro que aparece com o giro e some aos poucos.
	rastro.visible = true
	rastro.modulate.a = 0.8
	create_tween().tween_property(rastro, "modulate:a", 0.0, giro * 1.5)
	golpear_no_caminho()
	await volta.finished
	# Fim da volta: a faca passou por todo o círculo, então pega quem ainda faltava.
	golpear_no_caminho()
	faca.visible = false
	if faca2:
		faca2.visible = false
	await get_tree().create_timer(recarga - giro, false).timeout
	pode_atacar = true


# O golpe acompanha a lâmina: a panela dentro do círculo só leva o golpe quando a faca
# passa pelo ângulo dela, e cada panela leva no máximo um golpe por volta.
# Roda a cada quadro de física enquanto a faca gira (ver _physics_process).
func golpear_no_caminho() -> void:
	# A faca acerta a caixa Corpo da panela (do tamanho do desenho), não a base dos pés.
	for corpo in ataque.get_overlapping_areas():
		var inimigo = corpo.get_parent()
		var angulo := fposmod((inimigo.global_position - global_position).angle(), TAU)
		if not inimigo in acertadas_no_giro and angulo <= faca.rotation:
			if acertadas_no_giro.is_empty():
				Som.tocar("faca", -4.0)
			acertadas_no_giro.append(inimigo)
			inimigo.levar_golpe(dano)
		# A segunda lâmina começa meia volta à frente (em PI).
		if cutelo and not inimigo in acertadas_lamina2 and fposmod(angulo - PI, TAU) <= faca.rotation:
			acertadas_lamina2.append(inimigo)
			inimigo.levar_golpe(dano)


# Melhoria "faca maior": o círculo do golpe cresce e a faca cresce junto,
# com a ponta sempre 4 px além do raio (no começo, raio 24 e ponta em 28).
func aumentar_alcance(quanto: float) -> void:
	forma_ataque.radius += quanto
	faca.scale = Vector2.ONE * (forma_ataque.radius + 4.0) / 28.0
	if faca2:
		faca2.scale = faca.scale
	rastro.scale = Vector2.ONE * (forma_ataque.radius + 4.0) / 32.0


# Cutelo do Chef (a Faca maior no máximo): uma segunda lâmina do lado oposto
# e +2 de dano. As duas lâminas ficam douradas.
func evoluir_faca() -> void:
	cutelo = true
	dano += 2
	faca2 = faca.duplicate()
	faca2.visible = false
	ataque.add_child(faca2)
	faca.self_modulate = Color(1.15, 1.0, 0.7)
	faca2.self_modulate = faca.self_modulate
