extends Node2D

@onready var sound_death = $"../SoundDeath"
@onready var sound_damage = $"../SoundDamage"
@onready var sound_dodge = $"../SoundDodge"
@onready var sound_boom = $"../SoundBoom"
@onready var sound_ultimate = $"../SoundUltimate"
@onready var sound_boss_death = $"../SoundBossDeath"
@onready var sound_attack = $"../SoundAttack"

var color_mechanic
var pressed_buttons = []
var boss_health = 1000000
var attack_cooldown = false
var special_charge = 0.0

var canvas_layer : CanvasLayer
var darkness_overlay : ColorRect
var sound_attack_window = false
var dodged_sound_attack = false

var is_dodging = false
var dodge_cooldown = false
var original_position = Vector2.ZERO
var dodge_progress = 0.0
var dodge_duration = 0.6

var button_mapping = [0, 1, 2]

var arduino_buttons_down := {
	"button1": false,
	"button2": false,
	"button3": false
}
var special_combo_armed := true

var health := 100:
	set(value):
		var old_health = health
		health = clamp(value, 0, 100)
		if health != old_health:
			health_changed.emit(old_health, health)

signal health_changed(old_health: int, new_health: int)

@onready var anim = $AnimatedSprite2D

func _ready():
	color_mechanic = get_node("../ColorMechanic")
	var boss = get_node("../Boss")
	color_mechanic.combo_success.connect(_on_success)
	color_mechanic.combo_fail.connect(_on_fail)
	boss.button_mapping_changed.connect(_on_button_mapping_changed)
	boss.sound_attack_started.connect(_on_sound_attack)
	anim.play("idle")
	anim.animation_finished.connect(_on_animated_sprite_2d_animation_finished)
	ArduinoManager.button_event.connect(_on_arduino_button_event)
	ArduinoManager.ldr_changed.connect(_on_arduino_ldr_changed)
	_apply_button_mapping([0, 1, 2])
	health_changed.connect(_on_health_changed)

	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 10
	get_tree().get_root().add_child(canvas_layer)

	darkness_overlay = ColorRect.new()
	darkness_overlay.color = Color(0, 0, 0, 0)
	darkness_overlay.anchor_right = 1.0
	darkness_overlay.anchor_bottom = 1.0
	darkness_overlay.offset_right = 0
	darkness_overlay.offset_bottom = 0
	canvas_layer.add_child(darkness_overlay)

func _clear_darkness():
	if canvas_layer and is_instance_valid(canvas_layer):
		canvas_layer.queue_free()

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_A:
			_press_button(button_mapping[0])
		elif event.keycode == KEY_Z:
			_press_button(button_mapping[1])
		elif event.keycode == KEY_E:
			_press_button(button_mapping[2])
		elif event.keycode == KEY_R:
			_simple_attack()
		elif event.keycode == KEY_SPACE:
			_special_attack()
		elif event.keycode == KEY_F:
			_dodge()

	if event is InputEventKey and not event.pressed:
		if event.keycode == KEY_A:
			pressed_buttons.erase(button_mapping[0])
		elif event.keycode == KEY_Z:
			pressed_buttons.erase(button_mapping[1])
		elif event.keycode == KEY_E:
			pressed_buttons.erase(button_mapping[2])

func _press_button(btn: int):
	if btn not in pressed_buttons:
		pressed_buttons.append(btn)
	if color_mechanic.is_active:
		if color_mechanic.check_input(pressed_buttons):
			color_mechanic.is_active = false
			color_mechanic.emit_signal("combo_success", color_mechanic.current_color)
			pressed_buttons.clear()

func _simple_attack():
	if attack_cooldown:
		return
	attack_cooldown = true
	sound_attack.play() 
	anim.play("attack")
	var damage = 2000
	boss_health -= damage
	boss_health = clamp(boss_health, 0, 1000000)
	special_charge += 8
	special_charge = clamp(special_charge, 0, 100)
	if boss_health <= 0:
		sound_boss_death.play()
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://scenes/victory.tscn")
		return

func _on_animated_sprite_2d_animation_finished():
	if anim.animation == "attack" or anim.animation == "color_attack" or anim.animation == "ultimate_attack":
		anim.play("idle")
		attack_cooldown = false

func _special_attack():
	if special_charge < 100:
		return
	sound_ultimate.play()
	anim.play("ultimate_attack")
	boss_health -= 250000
	boss_health = clamp(boss_health, 0, 1000000)
	special_charge = 0
	if boss_health <= 0:
		sound_boss_death.play()
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://scenes/victory.tscn")

func _dodge():
	if is_dodging or dodge_cooldown:
		return
	is_dodging = true
	sound_dodge.play()
	if sound_attack_window:
		dodged_sound_attack = true
		print("Esquive son réussie !")
	original_position = position
	dodge_progress = 0.0

func _on_success(_color):
	anim.play("color_attack")
	boss_health -= 50000
	boss_health = clamp(boss_health, 0, 1000000)
	special_charge += 25
	special_charge = clamp(special_charge, 0, 100)
	if boss_health <= 0:
		sound_boss_death.play()
		await get_tree().create_timer(1.0).timeout  # laisser le son jouer
		get_tree().change_scene_to_file("res://scenes/victory.tscn")

func _on_fail():
	health -= 20
	health = clamp(health, 0, 100)
	sound_damage.play()
	_flash_damage()
	if health <= 0:
		_clear_darkness()
		sound_death.play()
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://scenes/gameover.tscn")

func _on_arduino_button_event(button_name: String, pressed: bool) -> void:
	if button_name in arduino_buttons_down:
		arduino_buttons_down[button_name] = pressed
		_check_arduino_special_combo()

	if not pressed:
		match button_name:
			"button1":
				pressed_buttons.erase(button_mapping[0])
			"button2":
				pressed_buttons.erase(button_mapping[1])
			"button3":
				pressed_buttons.erase(button_mapping[2])
		return

	match button_name:
		"button1":
			_press_button(button_mapping[0])
		"button2":
			_press_button(button_mapping[1])
		"button3":
			_press_button(button_mapping[2])
		"button4":
			_simple_attack()

func _on_arduino_ldr_changed(dark: bool) -> void:
	if dark:
		_dodge()

func _on_button_mapping_changed(new_mapping: Array) -> void:
	_apply_button_mapping(new_mapping)

func _update_led_mapping() -> void:
	var led1 = _game_color_to_arduino_color(button_mapping[0])
	var led2 = _game_color_to_arduino_color(button_mapping[1])
	var led3 = _game_color_to_arduino_color(button_mapping[2])
	ArduinoManager.send_led_mapping(led1, led2, led3)

func _game_color_to_arduino_color(game_color: int) -> int:
	match game_color:
		0:
			return 0
		1:
			return 2
		2:
			return 1
	return 0

func _apply_button_mapping(new_mapping: Array) -> void:
	button_mapping = new_mapping.duplicate()
	pressed_buttons.clear()
	_update_led_mapping()
	print("Nouveau mapping boutons : ", button_mapping)

func _check_arduino_special_combo() -> void:
	if (
		arduino_buttons_down["button1"]
		and arduino_buttons_down["button2"]
		and arduino_buttons_down["button3"]
	):
		if special_combo_armed:
			special_combo_armed = false
			_special_attack()
	else:
		special_combo_armed = true

func _on_health_changed(old_health: int, new_health: int) -> void:
	if new_health < old_health:
		ArduinoManager.send_vibration(200)

func _flash_damage():
	anim.modulate = Color(1, 0, 0, 1)
	await get_tree().create_timer(0.1).timeout
	anim.modulate = Color(1, 1, 1, 1)

func take_fatal_damage():
	ArduinoManager.send_vibration(200)
	_flash_damage()
	_clear_darkness()
	health = 0
	sound_death.play()
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/gameover.tscn")

func _on_sound_attack():
	dodged_sound_attack = false
	sound_attack_window = false

	var tween = create_tween()
	tween.tween_property(darkness_overlay, "color", Color(0, 0, 0, 0.85), 2.0)
	await get_tree().create_timer(2.0).timeout

	sound_boom.play()
	sound_attack_window = true

	await get_tree().create_timer(1.0).timeout
	sound_attack_window = false

	if not dodged_sound_attack:
		health -= 20
		sound_damage.play()
		_flash_damage()
		if health <= 0:
			_clear_darkness()
			sound_death.play()
			await get_tree().create_timer(1.0).timeout
			get_tree().change_scene_to_file("res://scenes/gameover.tscn")
			return

	var tween2 = create_tween()
	tween2.tween_property(darkness_overlay, "color", Color(0, 0, 0, 0), 2.0)

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
		var height = 150
		position.y = original_position.y + (4 * height * t * (t - 1))
