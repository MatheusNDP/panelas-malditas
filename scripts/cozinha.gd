# Origem: técnica dos roteiros da Aula 09 (Partes 2.3 e 4.3, o vila.gd, e ficha Defesa) e da Aula 10 (Parte 2.5, os abates), Prof. Ezéfferth, aplicada à cozinha.
extends Node2D

@export var cena_inimigo: PackedScene
@export var cena_frigideira: PackedScene
@export var cena_pressao: PackedScene
@export var cena_brava: PackedScene
@export var cena_chaleira: PackedScene
@export var cena_panelao: PackedScene
@export var cena_xp: PackedScene

var abates := 0
var fase_anunciada := 1
var nivel := 1
var xp := 0
var xp_proximo := 5
var panelao: Node2D = null
var panelao_veio := false

@onready var horda: Timer = $Horda
@onready var relogio: Timer = $Relogio
@onready var jogador := $Jogador
@onready var objeto := $Objeto
@onready var texto_vida: Label = $HUD/Vida
@onready var texto_tempo: Label = $HUD/Tempo
@onready var texto_caldeirao: Label = $HUD/Caldeirao
@onready var texto_fase: Label = $HUD/Fase
@onready var texto_nivel: Label = $HUD/Nivel
@onready var barra_xp: ColorRect = $HUD/BarraXP/Cheia
@onready var melhorias := $Melhorias
@onready var camera: Camera2D = $Camera
@onready var barra_chefe: Control = $HUD/Chefe
@onready var vida_chefe: ColorRect = $HUD/Chefe/Barra/Vida


func _ready() -> void:
	Som.tocar_musica()
	Partida.panelao_derrotado = false


func _process(_delta: float) -> void:
	texto_vida.text = "Vida: %d   Abates: %d" % [jogador.vida, abates]
	texto_tempo.text = "Fase %d   Tempo: %d" % [fase(), ceil(relogio.time_left)]
	texto_caldeirao.text = "Caldeirão: %d / %d" % [objeto.toques, objeto.limite]
	texto_nivel.text = "Nível %d" % nivel
	barra_xp.size.x = barra_xp.get_parent().size.x * xp / xp_proximo

	if fase() > fase_anunciada:
		fase_anunciada = fase()
		anunciar_fase()

	# O Panelão chega aos 2:15 (faltando 45 s) e a barra de vida dele aparece no alto.
	if not panelao_veio and relogio.wait_time - relogio.time_left >= 135.0:
		panelao_veio = true
		chamar_panelao()
	barra_chefe.visible = is_instance_valid(panelao)
	if barra_chefe.visible:
		vida_chefe.size.x = vida_chefe.get_parent().size.x * panelao.vida / panelao.vida_maxima


# Os 3 minutos têm três fases de 1 minuto: a cada uma, mais lugares
# de onde as panelas saem e tipos mais difíceis no sorteio.
func fase() -> int:
	var passado := relogio.wait_time - relogio.time_left
	if passado < 60:
		return 1
	if passado < 120:
		return 2
	return 3


func anunciar_fase() -> void:
	if fase_anunciada == 2:
		texto_fase.text = "Fase 2: os fogões acordaram, e a chaleira chegou!"
	else:
		texto_fase.text = "Fase 3: chegaram a pressão e a brava!"
	texto_fase.visible = true
	Som.tocar("fase", 0.0, false)
	await get_tree().create_timer(2.5).timeout
	texto_fase.visible = false


func chamar_panelao() -> void:
	panelao = cena_panelao.instantiate()
	panelao.global_position = $Nascedouros/Cima.global_position + Vector2(0, 8)
	add_child(panelao)
	soltar_particulas(panelao.global_position, Color(0.95, 0.95, 0.95), true)
	tremer(5.0)
	Som.tocar("fase", 0.0, false)
	texto_fase.text = "O Panelão chegou! Derrube-o antes do caldeirão!"
	texto_fase.visible = true
	await get_tree().create_timer(3.0).timeout
	texto_fase.visible = false


func _on_horda_timeout() -> void:
	# A horda aperta com o tempo: começa com uma panela a cada 2 s e chega
	# a uma a cada 0,5 s no começo da fase 3 (aos 120 s), e fica assim até o fim.
	var passado := relogio.wait_time - relogio.time_left
	horda.wait_time = max(0.5, 2.0 - 1.5 * passado / 120.0)

	var nascedouros := $Nascedouros.get_children()
	# Na fase 1 só as portas soltam panelas; os fogões e as pias acordam na fase 2.
	if fase() == 1:
		nascedouros = nascedouros.filter(func(n: Node) -> bool: return not n.has_node("Aviso"))
	var nascedouro: Node2D = nascedouros.pick_random()
	# Pelas portas a panela entra na hora. Dos fogões e das pias ela pula,
	# mas antes o aparelho pisca em vermelho por 1 s para dar tempo de chegar lá.
	if nascedouro.has_node("Aviso"):
		await piscar(nascedouro.get_node("Aviso"))
	soltar_panela(nascedouro.global_position)
	soltar_particulas(nascedouro.global_position, Color(0.95, 0.95, 0.95), true)


func soltar_panela(posicao: Vector2) -> void:
	var tipo := sortear_panela()
	var inimigo := tipo.instantiate()
	inimigo.global_position = posicao
	# Na fase 3 as panelas vêm mais duras: a comum aguenta 2 golpes e a de pressão 5.
	if fase() == 3:
		if tipo == cena_inimigo:
			inimigo.vida = 2
		elif tipo == cena_pressao:
			inimigo.vida = 5
	add_child(inimigo)


# Cada tipo de panela já sabe na própria cena quem persegue: as panelas comuns,
# a frigideira e a de pressão vão atrás do caldeirão; a brava vai atrás do chef.
# A chaleira para longe e cospe vapor no caldeirão.
# Fase 1: só comuns. Fase 2: entram a frigideira e a chaleira. Fase 3: a pressão e a brava.
func sortear_panela() -> PackedScene:
	var sorteio := randf()
	if fase() == 1:
		return cena_inimigo
	if fase() == 2:
		if sorteio < 0.25:
			return cena_frigideira
		if sorteio < 0.35:
			return cena_chaleira
		return cena_inimigo
	if sorteio < 0.2:
		return cena_frigideira
	if sorteio < 0.35:
		return cena_pressao
	if sorteio < 0.5:
		return cena_brava
	if sorteio < 0.65:
		return cena_chaleira
	return cena_inimigo


# Cada aviso é uma cópia do Aviso do nascedouro: assim duas panelas
# saindo do mesmo fogão em seguida não apagam o aviso uma da outra.
func piscar(modelo: ColorRect) -> void:
	var aviso := modelo.duplicate() as ColorRect
	aviso.visible = true
	modelo.get_parent().add_child(aviso)
	var chamas := soltar_chamas(aviso)
	var pisca := create_tween().set_loops(4)
	pisca.tween_property(aviso, "modulate:a", 0.2, 0.125)
	pisca.tween_property(aviso, "modulate:a", 1.0, 0.125)
	await pisca.finished
	aviso.queue_free()
	chamas.emitting = false
	get_tree().create_timer(chamas.lifetime).timeout.connect(chamas.queue_free)


# Enquanto o aviso pisca, o fogão solta chamas e a pia espirra água.
func soltar_chamas(aviso: ColorRect) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.position = aviso.position + aviso.size / 2
	p.z_index = 2
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(aviso.size.x / 2 - 4, 3)
	p.direction = Vector2.UP
	p.scale_amount_min = 2.5
	p.scale_amount_max = 4.5
	var cores := Gradient.new()
	if aviso.get_parent().name.begins_with("Fogao"):
		p.amount = 36
		p.lifetime = 0.55
		p.spread = 15.0
		p.gravity = Vector2(0, -60)
		p.initial_velocity_min = 15.0
		p.initial_velocity_max = 35.0
		cores.set_color(0, Color(1, 0.92, 0.45))
		cores.set_color(1, Color(0.85, 0.15, 0.08, 0))
		cores.add_point(0.4, Color(1, 0.5, 0.15))
	else:
		p.amount = 18
		p.lifetime = 0.5
		p.spread = 35.0
		p.gravity = Vector2(0, 220)
		p.initial_velocity_min = 35.0
		p.initial_velocity_max = 65.0
		cores.set_color(0, Color(0.8, 0.94, 1))
		cores.set_color(1, Color(0.35, 0.65, 0.95, 0))
	p.color_ramp = cores
	aviso.get_parent().add_child(p)
	p.emitting = true
	return p


func _on_relogio_timeout() -> void:
	vencer()


# No tipo Defesa os abates não decidem a vitória (quem decide é o relógio),
# mas cada panela derrubada solta bolinhas de XP para o chef subir de nível.
func inimigo_morreu(inimigo: Node2D) -> void:
	abates += 1
	soltar_xp(inimigo.global_position, inimigo.xp)
	if inimigo == panelao:
		Partida.panelao_derrotado = true
		tremer(6.0)
		for i in 3:
			soltar_particulas(inimigo.global_position + Vector2(randf_range(-10, 10), randf_range(-12, 4)), inimigo.cor_cacos)


# Cada bolinha de XP que chega no chef chama esta função.
func ganhar_xp(quanto: int) -> void:
	xp += quanto
	conferir_nivel()


# Cada nível pede 5 XP a mais que o anterior: 5, 10, 15, 20...
func conferir_nivel() -> void:
	if xp < xp_proximo or melhorias.visible:
		return
	xp -= xp_proximo
	nivel += 1
	xp_proximo += 5
	Som.tocar("nivel", 0.0, false)
	melhorias.abrir(nivel)


# Efeito de partículas que some sozinho: cacos caindo quando uma panela quebra,
# ou fumaça subindo quando uma panela nasce.
func soltar_particulas(posicao: Vector2, cor: Color, fumaca := false) -> void:
	var p := CPUParticles2D.new()
	p.position = posicao
	p.z_index = 2
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = 10 if fumaca else 14
	p.lifetime = 0.6 if fumaca else 0.5
	p.direction = Vector2.UP
	p.spread = 70.0 if fumaca else 180.0
	p.gravity = Vector2(0, -40) if fumaca else Vector2(0, 260)
	p.initial_velocity_min = 15.0 if fumaca else 50.0
	p.initial_velocity_max = 35.0 if fumaca else 110.0
	p.scale_amount_min = 2.0 if fumaca else 1.5
	p.scale_amount_max = 4.0 if fumaca else 3.0
	p.color = cor
	var some := Gradient.new()
	some.set_color(0, Color.WHITE)
	some.set_color(1, Color(1, 1, 1, 0))
	p.color_ramp = some
	p.finished.connect(p.queue_free)
	add_child(p)
	p.emitting = true


# A panela quebrada solta uma bolinha de XP por ponto, que se espalham um pouco pelo chão.
func soltar_xp(posicao: Vector2, quanto: int) -> void:
	for i in quanto:
		var bolinha := cena_xp.instantiate()
		bolinha.global_position = posicao
		add_child(bolinha)
		var destino := posicao + Vector2.from_angle(randf() * TAU) * randf_range(4.0, 6.0 + quanto * 0.8)
		bolinha.create_tween().tween_property(bolinha, "global_position", destino, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)


# A tela treme um pouco: o caldeirão apanhando, o chef se machucando.
func tremer(forca: float) -> void:
	var tremor := create_tween()
	for i in 6:
		tremor.tween_property(camera, "offset", Vector2(randf_range(-forca, forca), randf_range(-forca, forca)), 0.03)
	tremor.tween_property(camera, "offset", Vector2.ZERO, 0.03)


# call_deferred: troca de cena só no fim do quadro, quando a física terminou.
func vencer() -> void:
	Partida.terminar(true, "", abates, nivel, relogio.wait_time)
	get_tree().change_scene_to_file.call_deferred("res://scenes/fim.tscn")


# motivo: "caldeirao" quando a sopa se perde, "chef" quando o chef fica sem vida.
func perder(motivo := "caldeirao") -> void:
	Partida.terminar(false, motivo, abates, nivel, relogio.wait_time - relogio.time_left)
	get_tree().change_scene_to_file.call_deferred("res://scenes/fim.tscn")
