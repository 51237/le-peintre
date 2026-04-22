extends Node2D

var color_mechanic
var player

# Types d'attaques
enum AttackType { QUICK, HEAVY }

# Timers séparés pour chaque attaque
var quick_attack_timer = 0.0
var heavy_attack_timer = 0.0
var quick_attack_interval = 3.5   # attaque rapide toutes les 3.5s
var heavy_attack_interval = 4.0  # attaque lourde toutes les 10s
var color_attack_interval = 2.5   # combo couleur toutes les 5s
var color_attack_timer = 0.0
var projectile_scene = preload("res://scenes/projectile.tscn")
var heavy_projectile_scene = preload("res://scenes/heavy_projectile.tscn")

func _ready():
	player = get_node("../Player")
	color_mechanic = get_node("../ColorMechanic")
	# Décale les timers pour ne pas tout avoir en même temps
	quick_attack_timer = quick_attack_interval
	heavy_attack_timer = heavy_attack_interval
	color_attack_timer = color_attack_interval

func _process(delta):
	# Si le boss fait un combo couleur, il n'attaque pas
	if color_mechanic.is_active:
		return
	
	# Timer attaque rapide
	quick_attack_timer -= delta
	if quick_attack_timer <= 0:
		quick_attack_timer = quick_attack_interval
		_quick_attack()
	
	# Timer attaque lourde
	heavy_attack_timer -= delta
	if heavy_attack_timer <= 0:
		heavy_attack_timer = heavy_attack_interval
		_heavy_attack()
	
	# Timer combo couleur
	color_attack_timer -= delta
	if color_attack_timer <= 0:
		color_attack_timer = color_attack_interval
		_launch_color_attack()

func _quick_attack():
	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	projectile.z_index = 10
	var spawn_pos = Vector2(position.x - 300, position.y)
	var target_pos = Vector2(player.position.x +400, player.position.y +200)
	projectile.init(spawn_pos, target_pos, 8, Vector2(-650, -250))
	print("Attaque rapide lancée !")

func _heavy_attack():
	var projectile = heavy_projectile_scene.instantiate()
	get_parent().add_child(projectile)
	projectile.z_index = 10
	var spawn_pos = Vector2(position.x + 100, position.y)
	var target_pos = Vector2(player.position.x + 400, player.position.y +200)
	projectile.init(spawn_pos, target_pos, 20, Vector2(650, 250))
	print("Attaque lourde lancée !")
	
func _check_player_death():
	if player.health <= 0:
		get_tree().change_scene_to_file("res://scenes/gameover.tscn")

func _launch_color_attack():
	var random_color = randi() % 6
	color_mechanic.start_attack(random_color)
	print("Boss lance un combo couleur : ", random_color)
