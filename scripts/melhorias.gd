# Origem: escrito com auxílio de IA (Claude Code, assistente da Anthropic).
# Tela de subir de nível: o jogo pausa e o chef escolhe uma de três melhorias sorteadas.
# Ela continua rodando com o jogo pausado porque o process_mode dela é "When Paused".
# Cada arma sobe de nível pelo cartão dela; quando chega no nível 3, evolui sozinha.
# Uma evolução custa 3 cartões (a arma e mais 2 níveis).
extends CanvasLayer

# Cada opção aparece como um cartão: o desenho, o nome curto e, embaixo, uma etiqueta.
const TODAS := [
	{"id": "alcance", "nome": "Faca maior", "icone": preload("res://sprites/icone_faca_maior.png")},
	{"id": "recarga", "nome": "Golpe rápido", "icone": preload("res://sprites/icone_relogio.png")},
	{"id": "dano", "nome": "Faca afiada", "icone": preload("res://sprites/icone_faca_afiada.png")},
	{"id": "velocidade", "nome": "Botas", "icone": preload("res://sprites/icone_bota.png")},
	{"id": "vida", "nome": "Vida +1", "icone": preload("res://sprites/icone_coracao.png")},
	{"id": "caldeirao", "nome": "Caldeirão +1", "icone": preload("res://sprites/icone_caldeirao.png")},
]

# As armas novas: cada uma vira um filho do nó Armas do chef quando é escolhida.
const ARMAS := {
	"panelaco": {"cena": preload("res://entities/armas/panelaco.tscn"), "nome": "Panelaço", "icone": preload("res://sprites/icone_panelaco.png")},
	"garfos": {"cena": preload("res://entities/armas/garfos.tscn"), "nome": "Talheres", "icone": preload("res://sprites/icone_garfos.png")},
	"colheres": {"cena": preload("res://entities/armas/colheres.tscn"), "nome": "Colher suspeita", "icone": preload("res://sprites/icone_colheres.png")},
	"mel": {"cena": preload("res://entities/armas/mel.tscn"), "nome": "Pote de mel", "icone": preload("res://sprites/icone_mel.png")},
	"ratatui": {"cena": preload("res://entities/armas/ratatui.tscn"), "nome": "Ratatui", "icone": preload("res://sprites/icone_ratatui.png")},
}
const NIVEL_MAXIMO := 3
# Quantas armas o chef pode ter, sem contar a faca. Com o limite, escolher qual
# arma pegar importa: não dá para ter todas.
const LIMITE_ARMAS := 4

# Evoluções: só os utensílios evoluem, e sozinhos, quando chegam no nível 3.
const EVOLUCOES := {
	"panelaco": "Gongo",
	"garfos": "Faqueiro",
	"colheres": "Batucada",
	"mel": "Rastro de Mel",
	"ratatui": "Ninhada",
}
# A faca não tem cartão de nível: ela vira o Cutelo quando a Faca maior chega no
# máximo (raio 39, depois de 3 cartões de +5).
const CUTELO := "Cutelo do Chef"
const PASSO_ALCANCE := 5.0
const RAIO_MAXIMO := 39.0
const COR_EVOLUCAO := Color(1, 0.82, 0.3)

var opcoes := []

@onready var titulo: Label = $Titulo
@onready var botoes := [$Opcoes/Botao1, $Opcoes/Botao2, $Opcoes/Botao3]
@onready var cor_etiqueta: Color = $Opcoes/Botao1/Etiqueta.get_theme_color("font_color")


func abrir(nivel: int) -> void:
	opcoes = TODAS.filter(disponivel) + opcoes_de_armas()
	opcoes.shuffle()
	opcoes = opcoes.slice(0, 3)

	titulo.text = "Nível %d!" % nivel
	var jogador = get_tree().get_first_node_in_group("player")
	for i in botoes.size():
		botoes[i].visible = i < opcoes.size()
		if i < opcoes.size():
			botoes[i].get_node("Icone").texture = opcoes[i].icone
			botoes[i].get_node("Nome").text = opcoes[i].nome
			var etiqueta: Label = botoes[i].get_node("Etiqueta")
			etiqueta.text = opcoes[i].get("etiqueta", "")
			# O cartão que vai fazer algo evoluir avisa em dourado ("evolui: Gongo").
			var evolucao: String = opcoes[i].get("evolui", "")
			# O último cartão de Faca maior é o que faz a faca virar o Cutelo.
			if opcoes[i].id == "alcance" and jogador.forma_ataque.radius + PASSO_ALCANCE >= RAIO_MAXIMO:
				evolucao = "Cutelo"
			if evolucao != "":
				etiqueta.text = "evolui: " + evolucao
			etiqueta.add_theme_color_override("font_color", COR_EVOLUCAO if evolucao != "" else cor_etiqueta)

	visible = true
	get_tree().paused = true


func armas() -> Node:
	return get_tree().get_first_node_in_group("player").get_node("Armas")


# Uma opção por arma: "NOVA" se o chef ainda não tem (e não chegou no limite de armas),
# ou o próximo nível dela. Arma evoluída sai do sorteio.
func opcoes_de_armas() -> Array:
	var lista := []
	var cabe_mais := armas().get_child_count() < LIMITE_ARMAS
	for id in ARMAS:
		var arma := armas().get_node_or_null(id)
		if arma == null:
			if cabe_mais:
				lista.append({"id": "arma:" + id, "nome": ARMAS[id].nome, "icone": ARMAS[id].icone, "etiqueta": "NOVA"})
		elif arma.nivel < NIVEL_MAXIMO:
			var opcao := {"id": "arma:" + id, "nome": ARMAS[id].nome, "icone": ARMAS[id].icone, "etiqueta": "Nv %d" % (arma.nivel + 1)}
			if arma.nivel + 1 == NIVEL_MAXIMO:
				opcao.evolui = EVOLUCOES[id]
			lista.append(opcao)
	return lista


# Melhorias que já chegaram no limite saem do sorteio.
func disponivel(melhoria: Dictionary) -> bool:
	var jogador = get_tree().get_first_node_in_group("player")
	if melhoria.id == "alcance":
		return jogador.forma_ataque.radius < RAIO_MAXIMO
	if melhoria.id == "recarga":
		return jogador.recarga > 0.3
	return true


# Evolui tudo o que já chegou no nível 3. Devolve os nomes das evoluções.
func conferir_evolucoes() -> Array:
	var nomes := []
	for arma_id in EVOLUCOES:
		var arma := armas().get_node_or_null(arma_id)
		if arma and not arma.evoluida and arma.nivel >= NIVEL_MAXIMO:
			arma.evoluir()
			nomes.append(EVOLUCOES[arma_id])
	var jogador = get_tree().get_first_node_in_group("player")
	if not jogador.cutelo and jogador.forma_ataque.radius >= RAIO_MAXIMO:
		jogador.evoluir_faca()
		nomes.append(CUTELO)
	return nomes


func _unhandled_input(event: InputEvent) -> void:
	var tecla_evento := event as InputEventKey
	if not visible or tecla_evento == null or not tecla_evento.pressed:
		return
	var tecla := tecla_evento.keycode - KEY_1
	if tecla >= 0 and tecla < opcoes.size():
		escolher(tecla)


func escolher(i: int) -> void:
	aplicar(opcoes[i].id)
	visible = false
	get_tree().paused = false
	# O cartão pode ter levado uma arma (ou a faca) ao máximo: aí ela evolui na hora.
	var evoluiu := conferir_evolucoes()
	if not evoluiu.is_empty():
		get_tree().current_scene.anunciar_evolucao(", ".join(evoluiu))
	# Se o XP já dá para mais um nível, a tela abre de novo.
	get_tree().current_scene.conferir_nivel()


func aplicar(id: String) -> void:
	var jogador = get_tree().get_first_node_in_group("player")
	if id.begins_with("arma:"):
		var nome := id.trim_prefix("arma:")
		var arma = armas().get_node_or_null(nome)
		if arma:
			arma.subir_nivel()
		else:
			arma = ARMAS[nome].cena.instantiate()
			arma.name = nome
			armas().add_child(arma)
		return
	match id:
		"alcance":
			jogador.aumentar_alcance(PASSO_ALCANCE)
		"recarga":
			jogador.recarga = max(0.3, jogador.recarga * 0.85)
		"dano":
			jogador.dano += 1
		"velocidade":
			jogador.velocidade *= 1.15
		"vida":
			jogador.vida += 1
			jogador.vida_maxima += 1
		"caldeirao":
			get_tree().get_first_node_in_group("objeto").limite += 1


func _on_botao_1_pressed() -> void:
	escolher(0)


func _on_botao_2_pressed() -> void:
	escolher(1)


func _on_botao_3_pressed() -> void:
	escolher(2)
