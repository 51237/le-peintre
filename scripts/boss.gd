extends Node2D

var color_mechanic
var player

@onready var shield = $Shield

enum AttackType { QUICK, HEAVY }

var quick_attack_timer = 0.0
var heavy_attack_timer = 0.0
var quick_attack_interval = 4
var heavy_attack_interval = 10.0
var color_attack_interval = 2.5
var color_attack_timer = 0.0
var shield_timer = 0.0
var shield_interval = 20.0 

var projectile_scene = preload("res://scenes/projectile.tscn")
var heavy_projectile_scene = preload("res://scenes/heavy_projectile.tscn")

func _ready():
	player = get_node("../Player")
	color_mechanic = get_node("../ColorMechanic")
	color_mechanic.combo_success.connect(_on_combo_success)
	quick_attack_timer = quick_attack_interval
	heavy_attack_timer = heavy_attack_interval
	color_attack_timer = color_attack_interval
	color_mechanic.shield_broken.connect(_on_shield_broken)
	color_mechanic.shield_exploded.connect(_on_shield_exploded_boss)
	shield_timer = 15.0

func _process(delta):
	# Attaques normales
	quick_attack_timer -= delta
	if quick_attack_timer <= 0:
		quick_attack_timer = quick_attack_interval
		_quick_attack()
	
	heavy_attack_timer -= delta
	if heavy_attack_timer <= 0:
		heavy_attack_timer = heavy_attack_interval
		_heavy_attack()
	
	# Couleurs de base — indépendant du shield
	if not color_mechanic.is_active:
		color_attack_timer -= delta
		if color_attack_timer <= 0:
			color_attack_timer = color_attack_interval
			_launch_base_color_attack()
	
	# Shield — indépendant des couleurs de base
	if not color_mechanic.shield_active:
		shield_timer -= delta
		if shield_timer <= 0:
			shield_timer = shield_interval
			_launch_shield()

func _quick_attack():
	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	projectile.z_index = 10
	var spawn_pos = Vector2(position.x - 300, position.y)
	var target_pos = Vector2(player.position.x + 400, player.position.y + 200)
	projectile.init(spawn_pos, target_pos, 8, Vector2(-650, -250))
	print("Attaque rapide lancée !")

func _heavy_attack():
	var projectile = heavy_projectile_scene.instantiate()
	get_parent().add_child(projectile)
	projectile.z_index = 10
	var spawn_pos = Vector2(position.x + 100, position.y)
	var target_pos = Vector2(player.position.x + 400, player.position.y + 200)
	projectile.init(spawn_pos, target_pos, 20, Vector2(650, 250))
	print("Attaque lourde lancée !")

func _on_combo_success(_color):
	pass

func _launch_color_attack():
	var random_color = randi() % 6
	color_mechanic.start_attack(random_color)
	print("Boss lance un combo couleur : ", random_color)
	
	if color_mechanic.is_combo_color():
		var shield_color = color_mechanic.get_shield_color()
		shield.show_shield(shield_color)
		
func _launch_base_color_attack():
	var random_color = randi() % 3  # 0, 1, 2 = RED, BLUE, GREEN seulement
	color_mechanic.start_attack(random_color)
	print("Boss couleur de base : ", random_color)

func _launch_shield():
	var shield_colors = [3, 4, 5]  # PURPLE, CYAN, YELLOW
	var random_shield = shield_colors[randi() % 3]
	color_mechanic.start_shield(random_shield)
	var shield_color = color_mechanic.get_shield_color()
	$Shield.show_shield(shield_color)
	print("Boss active son shield !")

func _on_shield_broken():
	$Shield.flash_and_hide()

func _on_shield_exploded_boss():
	$Shield.flash_and_hide()
