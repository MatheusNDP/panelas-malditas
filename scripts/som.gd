# Toca os efeitos sonoros e a música. É um Autoload (Project Settings > Globals),
# então existe o jogo todo, sobrevive à troca de cena e qualquer script chama Som.tocar("nome").
extends Node

const SONS := {
	"faca": preload("res://sons/faca.wav"),
	"quebra": preload("res://sons/quebra.wav"),
	"acerto": preload("res://sons/acerto.wav"),
	"caldeirao": preload("res://sons/caldeirao.wav"),
	"dano": preload("res://sons/dano.wav"),
	"apito": preload("res://sons/apito.wav"),
	"chiado": preload("res://sons/chiado.wav"),
	"nivel": preload("res://sons/nivel.wav"),
	"fase": preload("res://sons/fase.wav"),
	"vitoria": preload("res://sons/vitoria.wav"),
	"derrota": preload("res://sons/derrota.wav"),
	"xp": preload("res://sons/xp.wav"),
	"panelaco": preload("res://sons/panelaco.wav"),
	"powerup": preload("res://sons/powerup.wav"),
	"pagina": preload("res://sons/pagina.wav"),
	"mel": preload("res://sons/mel.wav"),
}

var tocadores: Array[AudioStreamPlayer] = []
var ultima_vez := {}
var musica := AudioStreamPlayer.new()


func _ready() -> void:
	# Toca mesmo com o jogo pausado (o som de subir de nível sai com a pausa).
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Quem fecha o jogo é o _notification lá embaixo, depois de parar os sons.
	get_tree().auto_accept_quit = false
	for i in 8:
		var tocador := AudioStreamPlayer.new()
		add_child(tocador)
		tocadores.append(tocador)
	musica.stream = preload("res://sons/musica.wav")
	musica.volume_db = -10.0
	add_child(musica)


func tocar(nome: String, volume_db := 0.0, variar := true) -> void:
	# O mesmo som duas vezes no mesmo instante (três panelas quebrando juntas) toca uma vez só.
	var agora := Time.get_ticks_msec()
	if agora - ultima_vez.get(nome, -1000) < 60:
		return
	ultima_vez[nome] = agora

	for tocador in tocadores:
		if not tocador.playing:
			tocador.stream = SONS[nome]
			tocador.volume_db = volume_db
			# Um pouco mais grave ou mais agudo a cada vez, para não ficar repetitivo.
			tocador.pitch_scale = randf_range(0.92, 1.08) if variar else 1.0
			tocador.play()
			return


func tocar_musica() -> void:
	if not musica.playing:
		musica.play()


func parar_musica() -> void:
	musica.stop()


# Ao fechar a janela, os sons param e o jogo só sai 0,1 s depois.
# Saindo com a música tocando, a Godot avisava que ela ficou presa na memória.
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		musica.stop()
		for tocador in tocadores:
			tocador.stop()
		await get_tree().create_timer(0.1).timeout
		get_tree().quit()
