# Guarda o resumo da última partida para a tela de fim e o recorde de abates.
# É um Autoload, como o Som: a cozinha preenche no fim da partida e a tela de fim lê.
extends Node

const ARQUIVO := "user://recorde.cfg"

var venceu := false
# Na derrota: "caldeirao" (a sopa se perdeu) ou "chef" (o chef ficou sem vida).
var motivo := ""
var abates := 0
var nivel := 1
var tempo := 0.0
var recorde := 0
var novo_recorde := false
var panelao_derrotado := false


func _ready() -> void:
	var arquivo := ConfigFile.new()
	if arquivo.load(ARQUIVO) == OK:
		recorde = arquivo.get_value("recorde", "abates", 0)


func terminar(ganhou: bool, por: String, abates_feitos: int, nivel_final: int, segundos: float) -> void:
	venceu = ganhou
	motivo = por
	abates = abates_feitos
	nivel = nivel_final
	tempo = segundos
	novo_recorde = abates > recorde
	if novo_recorde:
		recorde = abates
		var arquivo := ConfigFile.new()
		arquivo.set_value("recorde", "abates", recorde)
		arquivo.save(ARQUIVO)
