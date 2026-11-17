# Power-up solto no chão: flutua com um brilho em volta, pisca nos últimos 3 s e some
# depois de 15 s. Quando o chef encosta, a cozinha aplica o efeito do tipo dele.
extends Area2D

const ARTES := {
	"ima": preload("res://sprites/power_ima.png"),
	"pimenta": preload("res://sprites/power_pimenta.png"),
	"coxinha": preload("res://sprites/power_coxinha.png"),
	"gelo": preload("res://sprites/power_gelo.png"),
	"concha": preload("res://sprites/power_concha.png"),
}
const DURACAO := 15.0

var tipo := "ima"
var tempo := 0.0
# Para onde o power-up pula ao nascer (quando sai de uma panela quebrada).
var pulo_ate := Vector2.ZERO

@onready var sprite: Sprite2D = $Sprite2D
@onready var brilho: Sprite2D = $Brilho


func _ready() -> void:
	sprite.texture = ARTES[tipo]
	if pulo_ate != global_position:
		create_tween().tween_property(self, "global_position", pulo_ate, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
	tempo += delta
	sprite.offset.y = sin(tempo * 3.0) * 2.0
	brilho.modulate.a = 0.35 + 0.25 * sin(tempo * 5.0)
	if tempo > DURACAO - 3.0:
		visible = int(tempo * 8.0) % 2 == 0
	if tempo > DURACAO:
		queue_free()


func _on_body_entered(_chef: Node2D) -> void:
	get_tree().current_scene.pegar_power_up(tipo, global_position)
	queue_free()
