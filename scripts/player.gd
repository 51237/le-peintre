extends Node2D

var color_mechanic
var pressed_buttons = []
var health = 100
var boss_health = 1000000
var attack_cooldown = false
var special_charge = 0.0  # de 0 à 100

func _ready():
	color_mechanic = get_node("../ColorMechanic")
	color_mechanic.combo_success.connect(_on_success)
	color_mechanic.combo_fail.connect(_on_fail)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_A:
			_press_button(0)
		elif event.keycode == KEY_Z:
			_press_button(1)
		elif event.keycode == KEY_E:
			_press_button(2)
		elif event.keycode == KEY_R:
			_simple_attack()
		elif event.keycode == KEY_SPACE:
			_special_attack()
		elif event.keycode == KEY_F:
			_dodge()

	if event is InputEventKey and not event.pressed:
		if event.keycode == KEY_A:
			pressed_buttons.erase(0)
		elif event.keycode == KEY_Z:
			pressed_buttons.erase(1)
		elif event.keycode == KEY_E:
			pressed_buttons.erase(2)

func _press_button(btn: int):
	if btn not in pressed_buttons:
		pressed_buttons.append(btn)
	if color_mechanic.is_active:
		if color_mechanic.check_input(pressed_buttons):
			color_mechanic.is_active = false
			color_mechanic.emit_signal("combo_success", color_mechanic.current_color)

func _simple_attack():
	if attack_cooldown:
		return
	var damage = 2000
	boss_health -= damage
	boss_health = clamp(boss_health, 0, 1000000)
	special_charge += 8
	special_charge = clamp(special_charge, 0, 100)
	print("Attaque simple — dégâts : ", damage, " | Charge : ", special_charge)
	if boss_health <= 0:
		get_tree().change_scene_to_file("res://scenes/victory.tscn")
		return
	attack_cooldown = true
	await get_tree().create_timer(0.5).timeout
	if is_inside_tree():
		attack_cooldown = false

func _special_attack():
	if special_charge < 100:
		print("Charge insuffisante : ", special_charge, "/100")
		return
	boss_health -= 250000
	boss_health = clamp(boss_health, 0, 1000000)
	special_charge = 0
	print("ATTAQUE SPECIALE ! Boss life : ", boss_health)
	if boss_health <= 0:
		get_tree().change_scene_to_file("res://scenes/victory.tscn")

func _dodge():
	print("Esquive !")
	# On ajoutera l'invincibilité après

func _on_success(_color):
	boss_health -= 50000
	boss_health = clamp(boss_health, 0, 1000000)
	special_charge += 25
	special_charge = clamp(special_charge, 0, 100)
	print("Boss life : ", boss_health, " | Charge : ", special_charge)
	if boss_health <= 0:
		get_tree().change_scene_to_file("res://scenes/victory.tscn")

func _on_fail():
	health -= 20
	health = clamp(health, 0, 100)
	print("Player life : ", health)
	if health <= 0:
		get_tree().change_scene_to_file("res://scenes/gameover.tscn")
