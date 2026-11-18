# Bolinha de XP: fica flutuando no chão onde a panela quebrou. Quando o chef chega
# perto (dentro do raio do ímã dele), ela é puxada cada vez mais rápido até ele e vira XP.
extends Sprite2D

# Quanto XP esta bolinha vale: a cozinha muda conforme a fase (verde 1, azul 1,5, vermelha 2).
var valor := 1.0
var puxando := false
var velocidade := 0.0
# Logo que nasce, a bolinha só se espalha; depois de 0,3 s já pode ser puxada.
var espera := 0.3
var tempo := randf() * TAU


func _process(delta: float) -> void:
	var chef := get_tree().get_first_node_in_group("player") as Node2D
	if chef == null:
		return

	espera -= delta
	if not puxando and espera <= 0.0 and global_position.distance_to(chef.global_position) <= chef.raio_ima:
		puxando = true

	if not puxando:
		tempo += delta
		offset.y = sin(tempo * 4.0) * 1.5
		return

	velocidade += 600.0 * delta
	global_position = global_position.move_toward(chef.global_position, velocidade * delta)
	if global_position.distance_to(chef.global_position) < 4.0:
		Som.tocar("xp", -10.0)
		get_tree().current_scene.ganhar_xp(valor)
		queue_free()
