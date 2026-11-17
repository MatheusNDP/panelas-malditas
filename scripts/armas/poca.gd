# A poça de azeite quente no chão: deixa as panelas lentas e queima a cada 0,5 s.
extends Area2D

var raio := 18.0
var dano := 1
var duracao := 3.0


func _ready() -> void:
	# Um círculo só desta poça, do tamanho que a arma mandou.
	var forma := CircleShape2D.new()
	forma.radius = raio
	$CollisionShape2D.shape = forma
	$Sprite2D.scale = Vector2.ONE * raio / 18.0
	modulate.a = 0.0
	var vida := create_tween()
	vida.tween_property(self, "modulate:a", 1.0, 0.2)
	vida.tween_interval(duracao)
	vida.tween_property(self, "modulate:a", 0.0, 0.4)
	vida.tween_callback(queue_free)


func _physics_process(_delta: float) -> void:
	for panela in get_overlapping_bodies():
		panela.lentidao = 0.3


func _on_queima_timeout() -> void:
	for panela in get_overlapping_bodies():
		panela.levar_golpe(dano)
