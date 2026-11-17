# O Panelão: a panela gigante do último minuto. É lenta e aguenta muitos golpes,
# e, quando chega ao caldeirão, fica batendo nele até alguém derrubá-la.
extends "res://scripts/inimigo.gd"

var vida_maxima := 0
var batendo := false

@onready var pancada: Timer = $Pancada


func _ready() -> void:
	super()
	vida_maxima = vida


func _physics_process(delta: float) -> void:
	if batendo:
		velocity = Vector2.ZERO
		return
	super(delta)


# O caldeirão chama esta função quando o Panelão encosta nele (as outras panelas somem na hora).
func encostou_no_caldeirao() -> void:
	batendo = true
	pancada.start()
	_on_pancada_timeout()


func _on_pancada_timeout() -> void:
	get_tree().get_first_node_in_group("objeto").levar_toque()
	# Uma "cabeçada": o desenho pula para cima e volta.
	var cabecada := create_tween()
	cabecada.tween_property(sprite, "offset", Vector2(0, -11), 0.08)
	cabecada.tween_property(sprite, "offset", Vector2(0, -6), 0.12)
