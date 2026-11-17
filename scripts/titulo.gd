# Tela de início: o nome do jogo, o elenco pulando, as instruções e o recorde.
extends Control

var tempo := 0.0

@onready var comecar: Label = $Comecar
@onready var elenco: Node2D = $Elenco
@onready var chef: Sprite2D = $Elenco/Chef


func _ready() -> void:
	Som.tocar_musica()
	$Recorde.text = "Recorde: %d abates" % Partida.recorde if Partida.recorde > 0 else ""


func _process(delta: float) -> void:
	tempo += delta
	comecar.modulate.a = 0.6 + 0.4 * sin(tempo * 4.0)

	# Cada personagem pula no seu tempo; o chef anda sem sair do lugar.
	var i := 0
	for boneco in elenco.get_children():
		boneco.position.y = -abs(sin(tempo * 6.0 + i * 0.7)) * 6.0
		i += 1
	chef.region_rect.position.x = int(tempo * 8.0) % 4 * 16

	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/cozinha.tscn")
