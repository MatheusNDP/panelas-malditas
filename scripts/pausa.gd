# Pausa com Esc: o jogo para e abre o livro de receitas do chef, com cada arma,
# tempero (melhoria), achado (power-up) e panela explicados ao lado do desenho.
# Roda sempre (process_mode Always) para ouvir o Esc com o jogo parado ou não.
extends CanvasLayer

# Cada seção ocupa uma página; o livro mostra duas por vez.
const SECOES := [
	{"titulo": "Utensílios", "itens": [
		[preload("res://sprites/icone_faca_maior.png"), "Faca", "Gira sozinha em volta do chef."],
		[preload("res://sprites/icone_panelaco.png"), "Panelaço", "Onda para todos os lados que empurra as panelas."],
		[preload("res://sprites/icone_garfos.png"), "Garfos", "Voam nas panelas mais perto e atravessam."],
		[preload("res://sprites/icone_colheres.png"), "Colheres", "Giram longe do chef, por fora da faca."],
		[preload("res://sprites/icone_mel.png"), "Pote de mel", "Poça grudenta que prende e machuca as panelas."],
	]},
	{"titulo": "Temperos", "itens": [
		[preload("res://sprites/icone_faca_maior.png"), "Faca maior", "A faca alcança mais longe."],
		[preload("res://sprites/icone_relogio.png"), "Golpe rápido", "A faca gira mais vezes."],
		[preload("res://sprites/icone_faca_afiada.png"), "Faca afiada", "Cada golpe tira mais."],
		[preload("res://sprites/icone_bota.png"), "Botas", "O chef anda mais rápido."],
		[preload("res://sprites/icone_coracao.png"), "Vida +1", "Mais uma vida para o chef."],
		[preload("res://sprites/icone_caldeirao.png"), "Caldeirão +1", "O caldeirão aguenta mais um toque."],
	]},
	{"titulo": "Achados da despensa", "itens": [
		[preload("res://sprites/power_ima.png"), "Ímã", "Todo o XP do chão vem até você."],
		[preload("res://sprites/power_pimenta.png"), "Pimenta", "Chef bem mais rápido por 8 s."],
		[preload("res://sprites/power_coxinha.png"), "Coxinha", "Recupera uma vida."],
		[preload("res://sprites/power_gelo.png"), "Gelo", "Congela as panelas por 4 s."],
		[preload("res://sprites/power_tampa.png"), "Tampa", "O caldeirão não leva toque por 6 s."],
	]},
	{"titulo": "Panelas rebeldes", "itens": [
		[preload("res://sprites/panela.png"), "Panela", "Vai direto no caldeirão."],
		[preload("res://sprites/frigideira.png"), "Frigideira", "Pequena e rápida."],
		[preload("res://sprites/panela_pressao.png"), "Pressão", "Lenta, mas aguenta vários golpes."],
		[preload("res://sprites/panela_brava.png"), "Brava", "Vem atrás do chef, não da sopa."],
		[preload("res://sprites/chaleira.png"), "Chaleira", "Cospe vapor de longe. Entre na frente!"],
		[preload("res://sprites/panelao.png"), "Panelão", "Chega no fim e bate no caldeirão sem parar."],
	]},
]
const TINTA := Color(0.36, 0.2, 0.14)
const TINTA_CLARA := Color(0.5, 0.36, 0.26)
const TITULO := Color(0.66, 0.18, 0.14)

# Número da página dupla aberta: 0 = páginas 1 e 2, 1 = páginas 3 e 4.
var aberta := 0

@onready var esquerda: VBoxContainer = $Esquerda
@onready var direita: VBoxContainer = $Direita
@onready var numero: Label = $Pagina


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if visible:
			continuar()
		# Com a tela de melhoria aberta o jogo já está pausado: aí o Esc não faz nada.
		elif not get_tree().paused:
			abrir()
		return
	if not visible:
		return
	if event.is_action_pressed("ui_left") or event.is_action_pressed("left"):
		virar(-1)
	elif event.is_action_pressed("ui_right") or event.is_action_pressed("right"):
		virar(1)
	else:
		var tecla := event as InputEventKey
		if tecla and tecla.pressed and tecla.keycode == KEY_M:
			voltar_ao_inicio()


func abrir() -> void:
	visible = true
	get_tree().paused = true
	mostrar()


func virar(lado: int) -> void:
	var nova: int = clamp(aberta + lado, 0, SECOES.size() / 2 - 1)
	if nova == aberta:
		return
	aberta = nova
	Som.tocar("pagina", -4.0)
	mostrar()


func mostrar() -> void:
	escrever(esquerda, SECOES[aberta * 2])
	escrever(direita, SECOES[aberta * 2 + 1])
	numero.text = "%d / %d" % [aberta + 1, SECOES.size() / 2]
	$Anterior.visible = aberta > 0
	$Proxima.visible = aberta < SECOES.size() / 2 - 1


# Escreve uma página: o título e, para cada item, o desenho com o nome e uma linha de explicação.
func escrever(pagina: VBoxContainer, secao: Dictionary) -> void:
	for filho in pagina.get_children():
		filho.queue_free()
	pagina.add_child(rotulo(secao.titulo, 16, TITULO))
	for item in secao.itens:
		var linha := HBoxContainer.new()
		linha.add_theme_constant_override("separation", 8)
		var desenho := TextureRect.new()
		desenho.texture = item[0]
		desenho.custom_minimum_size = Vector2(26, 26)
		desenho.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		desenho.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		linha.add_child(desenho)
		var textos := VBoxContainer.new()
		textos.add_theme_constant_override("separation", -2)
		textos.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		textos.add_child(rotulo(item[1], 11, TINTA))
		var explicacao := rotulo(item[2], 9, TINTA_CLARA)
		explicacao.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		explicacao.add_theme_constant_override("line_spacing", -4)
		textos.add_child(explicacao)
		linha.add_child(textos)
		pagina.add_child(linha)


func rotulo(texto: String, tamanho: int, cor: Color) -> Label:
	var r := Label.new()
	r.text = texto
	r.add_theme_font_size_override("font_size", tamanho)
	r.add_theme_color_override("font_color", cor)
	return r


func continuar() -> void:
	visible = false
	get_tree().paused = false


func voltar_ao_inicio() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/titulo.tscn")
