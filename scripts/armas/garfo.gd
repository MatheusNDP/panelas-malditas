# Um talher voando: anda reto, acerta as panelas no caminho e some na parede.
# Metade das vezes ele é um garfo e metade uma faca (só muda o desenho).
extends Area2D

const FACA := preload("res://sprites/faca_voando.png")

var direcao := Vector2.RIGHT
var velocidade := 230.0
var dano := 1
var atravessa := 1
var tempo_de_vida := 1.2


func _ready() -> void:
	rotation = direcao.angle()
	if randf() < 0.5:
		$Sprite2D.texture = FACA


func _physics_process(delta: float) -> void:
	position += direcao * velocidade * delta
	tempo_de_vida -= delta
	if tempo_de_vida <= 0.0:
		queue_free()


# Parede ou bancada: o talher para ali.
func _on_body_entered(_parede: Node2D) -> void:
	queue_free()


# Panela: acerta a caixa Corpo dela (do tamanho do desenho) e segue até gastar a força.
func _on_area_entered(corpo: Area2D) -> void:
	if atravessa <= 0:
		return
	corpo.get_parent().levar_golpe(dano)
	atravessa -= 1
	if atravessa <= 0:
		queue_free()
