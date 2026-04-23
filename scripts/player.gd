extends Node2D

var color_mechanic
var pressed_buttons = []
var health = 100
var boss_health = 1000000
var attack_cooldown = false
var special_charge = 0.0  # de 0 à 100

var is_dodging = false
var dodge_cooldown = false
var original_position = Vector2.ZERO
var dodge_progress = 0.0
var dodge_duration = 0.6  # durée du saut en secondes

@onready var anim = $AnimatedSprite2D

func _ready():
	color_mechanic = get_node("../ColorMechanic")
	color_mechanic.combo_success.connect(_on_success)
	color_mechanic.combo_fail.connect(_on_fail)
	color_mechanic.shield_exploded.connect(_on_shield_exploded)
	color_mechanic.shield_broken.connect(_on_shield_broken)
	anim.play("idle")  # ← idle au démarrage
	anim.animation_finished.connect(_on_animated_sprite_2d_animation_finished)
	ArduinoManager.button_event.connect(_on_arduino_button_event)
	ArduinoManager.ldr_changed.connect(_on_arduino_ldr_changed)
	ArduinoManager.send_led_mapping(0, 2, 1)
	
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

	# Vérifie couleurs de base
	if color_mechanic.is_active:
		if color_mechanic.check_input(pressed_buttons):
			color_mechanic.is_active = false
			color_mechanic.emit_signal("combo_success", color_mechanic.current_color)
			pressed_buttons.clear()
			return

	# Vérifie shield séparément
	if color_mechanic.shield_active:
		if color_mechanic.check_shield_input(pressed_buttons):
			color_mechanic.shield_active = false
			color_mechanic.emit_signal("shield_broken")
			pressed_buttons.clear()

func _simple_attack():
	if attack_cooldown:
		return
	attack_cooldown = true
	anim.play("attack")  # ← animation joue toujours
	
	# 0 dégâts si shield actif
	if color_mechanic.shield_active:
		print("Shield actif, 0 dégâts !")
		return
	
	var damage = 2000
	boss_health -= damage
	boss_health = clamp(boss_health, 0, 1000000)
	special_charge += 8
	special_charge = clamp(special_charge, 0, 100)
	if boss_health <= 0:
		get_tree().change_scene_to_file("res://scenes/victory.tscn")
		return

func _on_animated_sprite_2d_animation_finished():
	if anim.animation == "attack" or anim.animation == "color_attack" or anim.animation == "ultimate_attack":
		anim.play("idle")
		attack_cooldown = false

func _special_attack():
	if special_charge < 100:
		print("Charge insuffisante : ", special_charge, "/100")
		return
	anim.play("ultimate_attack")
	boss_health -= 250000
	boss_health = clamp(boss_health, 0, 1000000)
	special_charge = 0
	print("ATTAQUE SPECIALE ! Boss life : ", boss_health)
	if boss_health <= 0:
		get_tree().change_scene_to_file("res://scenes/victory.tscn")
		
func _dodge():
	if is_dodging or dodge_cooldown:
		print("Esquive non disponible !")
		return
	is_dodging = true
	original_position = position
	dodge_progress = 0.0
	print("Esquive !")

func _on_success(_color):
	anim.play("color_attack")
	var damage = 50000
	# 25% de dégâts en moins si shield actif
	if color_mechanic.shield_active:
		damage = int(damage * 0.75)
		print("Shield actif, dégâts réduits : ", damage)
	boss_health -= damage
	boss_health = clamp(boss_health, 0, 1000000)
	special_charge += 25
	special_charge = clamp(special_charge, 0, 100)
	if boss_health <= 0:
		get_tree().change_scene_to_file("res://scenes/victory.tscn")

func _on_fail():
	health -= 20
	health = clamp(health, 0, 100)
	ArduinoManager.send_vibration(200)
	_flash_damage()
	print("Player life : ", health)
	if health <= 0:
		get_tree().change_scene_to_file("res://scenes/gameover.tscn")
		
		
func _on_arduino_button_event(button_name: String, pressed: bool) -> void:
	if not pressed:
		match button_name:
			"button1":
				pressed_buttons.erase(0)
			"button2":
				pressed_buttons.erase(1)
			"button3":
				pressed_buttons.erase(2)
		return

	match button_name:
		"button1":
			_press_button(0)
		"button2":
			_press_button(1)
		"button3":
			_press_button(2)
		"button4":
			_simple_attack()

func _on_arduino_ldr_changed(dark: bool) -> void:
	if dark:
		_dodge()

func _flash_damage():
	anim.modulate = Color(1, 0, 0, 1)
	await get_tree().create_timer(0.1).timeout
	anim.modulate = Color(1, 1, 1, 1)

func take_fatal_damage():
	ArduinoManager.send_vibration(200)
	_flash_damage()
	health = 0
	get_tree().change_scene_to_file("res://scenes/gameover.tscn")
	
func _on_shield_exploded():
	health -= 30
	health = clamp(health, 0, 100)
	_flash_damage()
	print("Shield explosé ! Vie joueur : ", health)
	if health <= 0:
		get_tree().change_scene_to_file("res://scenes/gameover.tscn")

func _on_shield_broken():
	print("Shield détruit !")
	# bonus éventuel ici

func _process(delta):
	if is_dodging:
		dodge_progress += delta / dodge_duration
		
		if dodge_progress >= 1.0:
			dodge_progress = 1.0
			is_dodging = false
			position = original_position
			dodge_cooldown = true
			await get_tree().create_timer(1.0).timeout
			if is_inside_tree():
				dodge_cooldown = false
			return
		
		var t = dodge_progress
		var height = +150
		position.y = original_position.y + (4 * height * t * (t - 1))
