# Tela de subir de nível: o jogo pausa e o chef escolhe uma de três melhorias sorteadas.
# Ela continua rodando com o jogo pausado porque o process_mode dela é "When Paused".
extends CanvasLayer

# Cada opção aparece como um cartão: o desenho, o nome curto e, nas armas, "NOVA" ou o nível.
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
	"garfos": {"cena": preload("res://entities/armas/garfos.tscn"), "nome": "Garfos", "icone": preload("res://sprites/icone_garfos.png")},
	"colheres": {"cena": preload("res://entities/armas/colheres.tscn"), "nome": "Colheres", "icone": preload("res://sprites/icone_colheres.png")},
	"mel": {"cena": preload("res://entities/armas/mel.tscn"), "nome": "Pote de mel", "icone": preload("res://sprites/icone_mel.png")},
}
const NIVEL_MAXIMO := 5

var opcoes := []

@onready var titulo: Label = $Titulo
@onready var botoes := [$Opcoes/Botao1, $Opcoes/Botao2, $Opcoes/Botao3]


func abrir(nivel: int) -> void:
	opcoes = TODAS.filter(disponivel) + opcoes_de_armas()
	opcoes.shuffle()
	opcoes = opcoes.slice(0, 3)

	titulo.text = "Nível %d!" % nivel
	for i in botoes.size():
		botoes[i].visible = i < opcoes.size()
		if i < opcoes.size():
			botoes[i].get_node("Icone").texture = opcoes[i].icone
			botoes[i].get_node("Nome").text = opcoes[i].nome
			botoes[i].get_node("Etiqueta").text = opcoes[i].get("etiqueta", "")

	visible = true
	get_tree().paused = true


# Uma opção por arma: "NOVA" se o chef ainda não tem, ou o próximo nível dela.
func opcoes_de_armas() -> Array:
	var armas := get_tree().get_first_node_in_group("player").get_node("Armas")
	var lista := []
	for id in ARMAS:
		var arma := armas.get_node_or_null(id)
		if arma == null:
			lista.append({"id": "arma:" + id, "nome": ARMAS[id].nome, "icone": ARMAS[id].icone, "etiqueta": "NOVA"})
		elif arma.nivel < NIVEL_MAXIMO:
			lista.append({"id": "arma:" + id, "nome": ARMAS[id].nome, "icone": ARMAS[id].icone, "etiqueta": "Nv %d" % (arma.nivel + 1)})
	return lista


# Melhorias que já chegaram no limite saem do sorteio.
func disponivel(melhoria: Dictionary) -> bool:
	var jogador = get_tree().get_first_node_in_group("player")
	if melhoria.id == "alcance":
		return jogador.forma_ataque.radius < 40
	if melhoria.id == "recarga":
		return jogador.recarga > 0.3
	return true


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
	# Se o XP já dá para mais um nível, a tela abre de novo.
	get_tree().current_scene.conferir_nivel()


func aplicar(id: String) -> void:
	var jogador = get_tree().get_first_node_in_group("player")
	if id.begins_with("arma:"):
		var nome := id.trim_prefix("arma:")
		var arma = jogador.get_node("Armas").get_node_or_null(nome)
		if arma:
			arma.subir_nivel()
		else:
			arma = ARMAS[nome].cena.instantiate()
			arma.name = nome
			jogador.get_node("Armas").add_child(arma)
		return
	match id:
		"alcance":
			jogador.aumentar_alcance(4.0)
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
