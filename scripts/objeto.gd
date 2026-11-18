# Origem: ficha Defesa da folha da Aula 09 (Prof. Ezéfferth), aplicada ao caldeirão.
extends Area2D

var toques := 0
# Quantos toques o caldeirão aguenta; a melhoria "Caldeirão +1" aumenta.
var limite := 5
# Segundos que ainda faltam da Tampa (power-up): com ela o caldeirão não leva toque.
var tampa := 0.0

@onready var desenho_tampa: Sprite2D = $Tampa
@onready var fumaca: CPUParticles2D = $Fumaca


func _process(delta: float) -> void:
	tampa = max(0.0, tampa - delta)
	# A tampa fica em cima do caldeirão (e a fumaça some) e pisca no último 1,5 s.
	desenho_tampa.visible = tampa > 0.0 and (tampa > 1.5 or int(tampa * 8.0) % 2 == 0)
	fumaca.emitting = tampa == 0.0


func tampar(segundos: float) -> void:
	tampa = segundos


func _on_body_entered(inimigo: Node2D) -> void:
	# A panela brava só passa por cima: ela quer o chef, não a sopa.
	if inimigo.grupo_alvo != "objeto":
		return
	# O Panelão não some: ele fica batendo no caldeirão.
	if inimigo.has_method("encostou_no_caldeirao"):
		inimigo.encostou_no_caldeirao()
		return

	# A panela que chega na sopa ainda deixa 1 bolinha de XP: assim, quando o chef
	# começa a perder, ele não para de subir de nível também.
	get_tree().current_scene.soltar_xp(inimigo.global_position, 1)
	inimigo.queue_free()
	levar_toque()


# Um toque vem de uma panela que encostou ou do vapor da chaleira.
func levar_toque() -> void:
	# Tampado: a pancada bate na tampa, que pula e faz barulho, e o caldeirão não sente nada.
	if tampa > 0.0:
		Som.tocar("acerto", -2.0)
		get_tree().current_scene.soltar_particulas(desenho_tampa.global_position, Color(0.85, 0.88, 0.93))
		var pulo := create_tween()
		pulo.tween_property(desenho_tampa, "position:y", -15.0, 0.06)
		pulo.tween_property(desenho_tampa, "position:y", -11.0, 0.1)
		return
	toques += 1
	# O caldeirão pisca vermelho, a sopa espirra e a tela treme.
	$Sprite2D.modulate = Color(2.5, 0.6, 0.5)
	create_tween().tween_property($Sprite2D, "modulate", Color.WHITE, 0.3)
	get_tree().current_scene.soltar_particulas(global_position, Color(0.95, 0.55, 0.2))
	get_tree().current_scene.tremer(4.0)
	Som.tocar("caldeirao")
	if toques >= limite:
		get_tree().current_scene.perder()
