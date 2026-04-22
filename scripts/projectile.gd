extends Node2D

var start_pos = Vector2.ZERO
var end_pos = Vector2.ZERO
var control_point = Vector2.ZERO
var progress = 0.0
var speed = 1.2  # durée en secondes
var damage = 8

func init(from: Vector2, to: Vector2, dmg: int, ctrl_offset: Vector2 = Vector2(-550, -250)):
	start_pos = from
	end_pos = to
	damage = dmg
	position = from
	control_point = Vector2(
		from.x + ctrl_offset.x,
		from.y + ctrl_offset.y
	)

func _process(delta):
	progress += delta / speed
	if progress >= 1.0:
		progress = 1.0
		_on_hit()
		return
	# Calcul de la position sur la courbe de Bézier
	var t = progress
	position = (1 - t) * (1 - t) * start_pos + \
			   2 * (1 - t) * t * control_point + \
			   t * t * end_pos

func _on_hit():
	var player = get_node("/root/Game/Player")
	print("is_dodging : ", player.is_dodging)
	if player.is_dodging:
		print("Esquive réussie !")
		queue_free()
		return
	# ICI les dégâts — en dehors du if !
	player.health -= damage
	player.health = clamp(player.health, 0, 100)
	print("Projectile touche le joueur ! Vie : ", player.health)
	if player.health <= 0:
		get_tree().change_scene_to_file("res://scenes/gameover.tscn")
	queue_free()
