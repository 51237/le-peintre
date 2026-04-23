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

var projectile_scene = preload("res://scenes/projectile.tscn")
var heavy_projectile_scene = preload("res://scenes/heavy_projectile.tscn")

func _ready():
	player = get_node("../Player")
	color_mechanic = get_node("../ColorMechanic")
	color_mechanic.combo_success.connect(_on_combo_success)
	quick_attack_timer = quick_attack_interval
	heavy_attack_timer = heavy_attack_interval
	color_attack_timer = color_attack_interval

func _process(delta):
	# Attaques rapides et lourdes continuent même si combo actif
	quick_attack_timer -= delta
	if quick_attack_timer <= 0:
		quick_attack_timer = quick_attack_interval
		_quick_attack()
	
	heavy_attack_timer -= delta
	if heavy_attack_timer <= 0:
		heavy_attack_timer = heavy_attack_interval
		_heavy_attack()
	
	# Nouvelles couleurs bloquées si combo déjà actif
	if color_mechanic.is_active:
		return
	
	color_attack_timer -= delta
	if color_attack_timer <= 0:
		color_attack_timer = color_attack_interval
		_launch_color_attack()

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
	shield.flash_and_hide()

func _launch_color_attack():
	var random_color = randi() % 6
	color_mechanic.start_attack(random_color)
	print("Boss lance un combo couleur : ", random_color)
	
	if color_mechanic.is_combo_color():
		var shield_color = color_mechanic.get_shield_color()
		shield.show_shield(shield_color)
