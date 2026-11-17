# Tela de subir de nível: o jogo pausa e o chef escolhe uma de três melhorias sorteadas.
# Ela continua rodando com o jogo pausado porque o process_mode dela é "When Paused".
extends CanvasLayer

const TODAS := [
	{"id": "alcance", "nome": "Faca maior", "texto": "alcance +4"},
	{"id": "recarga", "nome": "Golpe mais rápido", "texto": "recarga 15% menor"},
	{"id": "dano", "nome": "Faca afiada", "texto": "dano +1"},
	{"id": "velocidade", "nome": "Botas de cozinha", "texto": "chef 15% mais rápido"},
	{"id": "vida", "nome": "Avental reforçado", "texto": "vida +1"},
	{"id": "caldeirao", "nome": "Tampa no caldeirão", "texto": "aguenta +1 toque"},
	{"id": "ima", "nome": "Ímã de geladeira", "texto": "puxa o XP de mais longe"},
]

var opcoes := []

@onready var titulo: Label = $Titulo
@onready var botoes := [$Opcoes/Botao1, $Opcoes/Botao2, $Opcoes/Botao3]


func abrir(nivel: int) -> void:
	opcoes = TODAS.filter(disponivel)
	opcoes.shuffle()
	opcoes = opcoes.slice(0, 3)

	titulo.text = "Nível %d! Escolha uma melhoria" % nivel
	for i in botoes.size():
		botoes[i].visible = i < opcoes.size()
		if i < opcoes.size():
			botoes[i].text = "%d. %s\n%s" % [i + 1, opcoes[i].nome, opcoes[i].texto]

	visible = true
	get_tree().paused = true


# Melhorias que já chegaram no limite saem do sorteio.
func disponivel(melhoria: Dictionary) -> bool:
	var jogador = get_tree().get_first_node_in_group("player")
	if melhoria.id == "alcance":
		return jogador.forma_ataque.radius < 40
	if melhoria.id == "recarga":
		return jogador.recarga > 0.3
	if melhoria.id == "ima":
		return jogador.raio_ima < 120
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
		"caldeirao":
			get_tree().get_first_node_in_group("objeto").limite += 1
		"ima":
			jogador.raio_ima += 28.0


func _on_botao_1_pressed() -> void:
	escolher(0)


func _on_botao_2_pressed() -> void:
	escolher(1)


func _on_botao_3_pressed() -> void:
	escolher(2)
