extends Node

enum PaintColor { RED, BLUE, GREEN, PURPLE, CYAN, YELLOW }

const COLOR_COMBOS = {
	PaintColor.RED:    [0],
	PaintColor.BLUE:   [1],
	PaintColor.GREEN:  [2],
	PaintColor.PURPLE: [0, 1],
	PaintColor.CYAN:   [1, 2],
	PaintColor.YELLOW: [0, 2],
}

# Système couleurs de base
var current_color = PaintColor.RED
var time_limit = 3.0
var time_left = 3.0
var is_active = false

# Système shield — complètement séparé
var shield_active = false
var shield_color = PaintColor.PURPLE
var shield_time_left = 15.0
var shield_cooldown = 0.0
var shield_cooldown_duration = 10.0
var shield_was_active = false  # pour détecter la fin du shield

signal combo_success(color)
signal combo_fail
signal shield_broken
signal shield_exploded

func start_attack(color: PaintColor):
	current_color = color
	time_left = time_limit
	is_active = true

func start_shield(color: PaintColor):
	if shield_cooldown > 0:
		return  # shield en cooldown
	shield_color = color
	shield_time_left = 15.0
	shield_active = true
	shield_was_active = true

func check_input(pressed_buttons: Array) -> bool:
	var expected = COLOR_COMBOS[current_color]
	if pressed_buttons.size() == expected.size():
		for btn in expected:
			if btn not in pressed_buttons:
				return false
		return true
	return false

func check_shield_input(pressed_buttons: Array) -> bool:
	var expected = COLOR_COMBOS[shield_color]
	if pressed_buttons.size() == expected.size():
		for btn in expected:
			if btn not in pressed_buttons:
				return false
		return true
	return false

func get_shield_color() -> Color:
	match shield_color:
		PaintColor.PURPLE: return Color(0.5, 0, 0.5)
		PaintColor.CYAN:   return Color(0, 1, 1)
		PaintColor.YELLOW: return Color(1, 1, 0)
	return Color(1, 1, 1)

func _process(delta):
	# Système couleurs de base
	if is_active:
		time_left -= delta
		if time_left <= 0:
			is_active = false
			emit_signal("combo_fail")

	# Système shield
	if shield_active:
		shield_time_left -= delta
		if shield_time_left <= 0:
			shield_active = false
			shield_was_active = false
			shield_cooldown = shield_cooldown_duration
			emit_signal("shield_exploded")

	# Cooldown shield
	if shield_cooldown > 0:
		shield_cooldown -= delta
