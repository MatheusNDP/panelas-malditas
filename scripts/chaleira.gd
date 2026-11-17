# A chaleira não encosta no caldeirão: ela para a uma distância dele e cospe vapor.
# Quem fica parado no centro perde toques, então o chef precisa ir até ela.
extends "res://scripts/inimigo.gd"

@export var distancia_tiro: float = 80.0
@export var cena_vapor: PackedScene

var parada := false
var apitou := false

@onready var cuspe: Timer = $Cuspe


func _physics_process(delta: float) -> void:
	var alvo := get_tree().get_first_node_in_group(grupo_alvo) as Node2D
	parada = alvo != null and global_position.distance_to(alvo.global_position) <= distancia_tiro
	if not parada:
		cuspe.stop()
		super(delta)
		return

	velocity = Vector2.ZERO
	if cuspe.is_stopped():
		cuspe.start()


# Meio segundo antes de cuspir, a chaleira apita: fica clara e treme.
func _process(delta: float) -> void:
	super(delta)
	if parada and cuspe.time_left < 0.5:
		if not apitou:
			apitou = true
			Som.tocar("apito", -8.0)
		sprite.self_modulate = Color(1.6, 1.6, 1.6)
		sprite.offset = Vector2(randf_range(-1, 1), randf_range(-1, 1))
	else:
		sprite.self_modulate = Color.WHITE
		sprite.offset = Vector2.ZERO


func _on_cuspe_timeout() -> void:
	apitou = false
	var alvo := get_tree().get_first_node_in_group(grupo_alvo) as Node2D
	if alvo == null:
		return
	var vapor := cena_vapor.instantiate()
	vapor.global_position = global_position
	vapor.destino = alvo.global_position
	get_tree().current_scene.add_child(vapor)
