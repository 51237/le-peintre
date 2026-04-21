extends Area2D

var speed = 400.0
var target_position = Vector2.ZERO
var damage = 8

func init(start_pos: Vector2, target_pos: Vector2, dmg: int):
	position = start_pos
	target_position = target_pos
	damage = dmg
	$Sprite.play("default")

func _process(delta):
	var direction = (target_position - position).normalized()
	position += direction * speed * delta
	
	# Rotation vers la cible
	rotation = direction.angle()
	
	# Si on est arrivé à destination
	if position.distance_to(target_position) < 20:
		_on_hit()

func _on_hit():
	var player = get_node("/root/Game/Player")
	player.health -= damage
	player.health = clamp(player.health, 0, 100)
	print("Projectile touche le joueur ! Vie : ", player.health)
	queue_free()
