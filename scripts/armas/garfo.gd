# Um garfo voando: anda reto, acerta as panelas no caminho e some na parede.
extends Area2D

var direcao := Vector2.RIGHT
var velocidade := 230.0
var dano := 1
var atravessa := 1
var tempo_de_vida := 1.2


func _ready() -> void:
	rotation = direcao.angle()


func _physics_process(delta: float) -> void:
	position += direcao * velocidade * delta
	tempo_de_vida -= delta
	if tempo_de_vida <= 0.0:
		queue_free()


func _on_body_entered(corpo: Node2D) -> void:
	# Parede ou bancada: o garfo para ali.
	if not corpo.has_method("levar_golpe"):
		queue_free()
		return
	corpo.levar_golpe(dano)
	atravessa -= 1
	if atravessa <= 0:
		queue_free()
