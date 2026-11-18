# Origem: técnica dos roteiros da Aula 09 (Partes 2.3 e 4.3, o vila.gd, e ficha Defesa) e da Aula 10 (Parte 2.5, os abates), Prof. Ezéfferth, aplicada à cozinha.
extends Node2D

@export var cena_inimigo: PackedScene
@export var cena_frigideira: PackedScene
@export var cena_pressao: PackedScene
@export var cena_brava: PackedScene
@export var cena_chaleira: PackedScene
@export var cena_panelao: PackedScene
@export var cena_xp: PackedScene
@export var cena_power_up: PackedScene

const XP_POR_FASE := {
	1: {"arte": preload("res://sprites/xp.png"), "valor": 1.0},
	2: {"arte": preload("res://sprites/xp_azul.png"), "valor": 1.5},
	3: {"arte": preload("res://sprites/xp_vermelho.png"), "valor": 2.0},
}

var abates := 0
var fase_anunciada := 1
var nivel := 1
# O XP é quebrado (float) porque as bolinhas azuis valem 1,5.
var xp := 0.0
var xp_proximo := 5
var panelao: Node2D = null
# Power-ups que já foram soltos mas ainda não entraram na cena (entram no fim do quadro).
var power_ups_chegando := 0
var panelao_veio := false
# Depois de vencer, o jogador pode continuar a mesma partida: a hora extra, no ritmo
# da fase 3, que só acaba quando ele perde.
var hora_extra := false
var tempo_extra := 0.0

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
	Partida.hora_extra = 0.0


func _process(delta: float) -> void:
	texto_vida.text = "Vida: %d   Abates: %d" % [jogador.vida, abates]
	texto_tempo.text = "Fase %d   Tempo: %d" % [fase(), ceil(relogio.time_left)]
	# Na hora extra o relógio conta para cima o tempo a mais.
	if hora_extra:
		tempo_extra += delta
		texto_tempo.text = "Hora extra: %d:%02d" % [int(tempo_extra) / 60, int(tempo_extra) % 60]
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
	texto_fase.text = "Fase %d" % fase_anunciada
	texto_fase.visible = true
	Som.tocar("fase", 0.0, false)
	await get_tree().create_timer(2.5).timeout
	texto_fase.visible = false


func chamar_panelao() -> void:
	panelao = cena_panelao.instantiate()
	# Ele entra pela porta da esquerda, um pouco para dentro da sala.
	panelao.global_position = $Nascedouros/Esquerda.global_position + Vector2(8, 0)
	add_child(panelao)
	soltar_particulas(panelao.global_position, Color(0.95, 0.95, 0.95), true)
	tremer(5.0)
	Som.tocar("fase", 0.0, false)
	texto_fase.text = "PANELÃO!"
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
	# A cada fase as panelas vêm mais duras: +1 de vida na fase 2 e +2 na fase 3,
	# em cima da vida de cada tipo (a comum aguenta 1, 2 e 3 golpes).
	inimigo.vida += fase() - 1
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
	# Às vezes a panela solta um power-up (o Panelão solta dois); no máximo 5 no chão.
	var quantos := 2 if inimigo == panelao else (1 if randf() < inimigo.chance_power_up else 0)
	for i in quantos:
		if power_ups_no_chao() < 5:
			soltar_power_up(inimigo.global_position, inimigo.global_position + Vector2.from_angle(randf() * TAU) * 14.0)
	if inimigo == panelao:
		Partida.panelao_derrotado = true
		tremer(6.0)
		for i in 3:
			soltar_particulas(inimigo.global_position + Vector2(randf_range(-10, 10), randf_range(-12, 4)), inimigo.cor_cacos)


# Cada bolinha de XP que chega no chef chama esta função.
func ganhar_xp(quanto: float) -> void:
	xp += quanto
	conferir_nivel()


# Cada nível pede 3 XP a mais que o anterior: 5, 8, 11, 14...
# (Era +5, e no fim da partida o chef demorava demais para subir.)
func conferir_nivel() -> void:
	if xp < xp_proximo or melhorias.visible:
		return
	xp -= xp_proximo
	nivel += 1
	xp_proximo += 3
	Som.tocar("nivel", 0.0, false)
	melhorias.abrir(nivel)


# Uma arma chegou no nível 3 (ou a faca no raio máximo) e evoluiu: brilho dourado,
# o som de fase e o nome da evolução em letras grandes no meio da tela.
func anunciar_evolucao(nome: String) -> void:
	efeito_evolucao()
	texto_fase.text = "%s!" % nome.to_upper()
	texto_fase.visible = true
	await get_tree().create_timer(2.5).timeout
	texto_fase.visible = false


# Brilho dourado em volta do chef e o som de fase.
func efeito_evolucao() -> void:
	Som.tocar("fase", 0.0, false)
	for i in 4:
		soltar_particulas(jogador.global_position + Vector2.from_angle(TAU * i / 4) * 10, Color(1, 0.85, 0.35), true)


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
# A cor e o valor da bolinha mudam com a fase, porque as panelas também ficam mais duras:
# verde vale 1 (fase 1), azul vale 1,5 (fase 2) e vermelha vale 2 (fase 3).
func soltar_xp(posicao: Vector2, quanto: int) -> void:
	for i in quanto:
		var bolinha := cena_xp.instantiate()
		bolinha.global_position = posicao
		bolinha.texture = XP_POR_FASE[fase()].arte
		bolinha.valor = XP_POR_FASE[fase()].valor
		add_child(bolinha)
		var destino := posicao + Vector2.from_angle(randf() * TAU) * randf_range(4.0, 6.0 + quanto * 0.8)
		bolinha.create_tween().tween_property(bolinha, "global_position", destino, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)


# A cada 12 s um power-up aparece num lugar sorteado do chão (no máximo 3 ao mesmo tempo).
func _on_power_ups_timeout() -> void:
	if power_ups_no_chao() >= 3:
		return
	# Um ponto do mapa de navegação é sempre chão livre; longe do chef, para ele ter que ir buscar.
	var lugar := Vector2.ZERO
	for tentativa in 10:
		lugar = NavigationServer2D.map_get_random_point(get_world_2d().navigation_map, 1, false)
		if lugar.distance_to(jogador.global_position) > 60.0:
			break
	soltar_power_up(lugar, lugar)


func power_ups_no_chao() -> int:
	return get_tree().get_nodes_in_group("power_up").size() + power_ups_chegando


# A Coxinha só vale com o chef machucado.
func sortear_power_up() -> String:
	var tipos := ["ima", "ima", "pimenta", "gelo", "tampa"]
	if jogador.vida < jogador.vida_maxima:
		tipos.append("coxinha")
	return tipos.pick_random()


# O power-up nasce em "origem" e pula até "destino" (os dois iguais quando vem do timer).
func soltar_power_up(origem: Vector2, destino: Vector2) -> void:
	var power_up := cena_power_up.instantiate()
	power_up.tipo = sortear_power_up()
	power_up.global_position = origem
	power_up.pulo_ate = destino
	power_ups_chegando += 1
	power_up.tree_entered.connect(func() -> void: power_ups_chegando -= 1, CONNECT_ONE_SHOT)
	# call_deferred: a panela pode quebrar dentro de um sinal de física (garfo, colher),
	# e uma Area2D nova só pode entrar na cena depois que a física termina.
	add_child.call_deferred(power_up)


func pegar_power_up(tipo: String, posicao: Vector2) -> void:
	Som.tocar("powerup", 0.0, false)
	soltar_particulas(posicao, Color(1, 0.9, 0.5), true)
	match tipo:
		"ima":
			mostrar_texto("Ímã!")
			for bolinha in get_children():
				if bolinha.scene_file_path.ends_with("xp.tscn"):
					bolinha.espera = 0.0
					bolinha.puxando = true
		"pimenta":
			mostrar_texto("Pimenta!")
			jogador.pressa = 8.0
		"coxinha":
			mostrar_texto("Coxinha!")
			jogador.vida = min(jogador.vida + 1, jogador.vida_maxima)
		"gelo":
			mostrar_texto("Gelo!")
			congelar_panelas(4.0)
		"tampa":
			mostrar_texto("Tampa!")
			objeto.tampar(6.0)


# Todas as panelas param por uns segundos: o process_mode desligado congela o movimento,
# os timers (o cuspe da chaleira, a pancada do Panelão) e as animações delas.
# O disable_mode KEEP_ACTIVE deixa o corpo na física mesmo desligado: sem ele a panela
# congelada sairia do mundo físico e as armas passariam direto por ela.
func congelar_panelas(segundos: float) -> void:
	var congeladas := get_tree().get_nodes_in_group("inimigo")
	for panela in congeladas:
		panela.disable_mode = CollisionObject2D.DISABLE_MODE_KEEP_ACTIVE
		panela.process_mode = Node.PROCESS_MODE_DISABLED
		panela.modulate = Color(0.6, 0.85, 1.4)
	await get_tree().create_timer(segundos, false).timeout
	for panela in congeladas:
		if is_instance_valid(panela):
			panela.process_mode = Node.PROCESS_MODE_INHERIT
			panela.modulate = Color.WHITE


# Um aviso curto que sobe da cabeça do chef e some.
func mostrar_texto(texto: String) -> void:
	var aviso := Label.new()
	aviso.text = texto
	aviso.z_index = 3
	aviso.size = Vector2(240, 14)
	aviso.position = jogador.global_position - Vector2(120, 28)
	aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	aviso.add_theme_font_size_override("font_size", 10)
	aviso.add_theme_color_override("font_color", Color(1, 0.9, 0.45))
	aviso.add_theme_color_override("font_outline_color", Color(0.16, 0.07, 0.08))
	aviso.add_theme_constant_override("outline_size", 4)
	add_child(aviso)
	var sobe := create_tween().set_parallel()
	sobe.tween_property(aviso, "position:y", aviso.position.y - 18, 1.4).set_ease(Tween.EASE_OUT)
	sobe.tween_property(aviso, "modulate:a", 0.0, 0.6).set_delay(0.9)
	sobe.chain().tween_callback(aviso.queue_free)


# A tela treme um pouco: o caldeirão apanhando, o chef se machucando.
func tremer(forca: float) -> void:
	var tremor := create_tween()
	for i in 6:
		tremor.tween_property(camera, "offset", Vector2(randf_range(-forca, forca), randf_range(-forca, forca)), 0.03)
	tremor.tween_property(camera, "offset", Vector2.ZERO, 0.03)


# Venceu os 3 minutos: a tela de fim aparece por cima da cozinha, com o jogo pausado,
# para dar para continuar a mesma partida (a hora extra) pelo botão "Continuar Jogando".
func vencer() -> void:
	Partida.terminar(true, "", abates, nivel, relogio.wait_time)
	var tela := CanvasLayer.new()
	tela.layer = 20
	tela.process_mode = Node.PROCESS_MODE_ALWAYS
	tela.add_child(preload("res://scenes/fim.tscn").instantiate())
	add_child(tela)
	get_tree().paused = true


# O botão "Continuar Jogando" da vitória: a horda segue no ritmo da fase 3 até o jogador perder.
func continuar_hora_extra() -> void:
	hora_extra = true
	get_tree().paused = false
	Som.tocar_musica()
	texto_fase.text = "HORA EXTRA!"
	texto_fase.visible = true
	await get_tree().create_timer(2.5).timeout
	texto_fase.visible = false


# motivo: "caldeirao" quando a sopa se perde, "chef" quando o chef fica sem vida.
# call_deferred: troca de cena só no fim do quadro, quando a física terminou.
func perder(motivo := "caldeirao") -> void:
	Partida.hora_extra = tempo_extra
	Partida.terminar(false, motivo, abates, nivel, relogio.wait_time - relogio.time_left + tempo_extra)
	get_tree().change_scene_to_file.call_deferred("res://scenes/fim.tscn")
