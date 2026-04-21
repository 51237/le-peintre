extends Node2D

var color_mechanic
var pressed_buttons = []
var health = 100
var boss_health = 100

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

func _on_success(_color):
	boss_health -= 15
	boss_health = clamp(boss_health, 0, 100)
	print("Boss life : ", boss_health)
	if boss_health <= 0:
		get_tree().change_scene_to_file("res://scenes/victory.tscn")

func _on_fail():
	health -= 20
	health = clamp(health, 0, 100)
	print("Player life : ", health)
	if health <= 0:
		get_tree().change_scene_to_file("res://scenes/gameover.tscn")
