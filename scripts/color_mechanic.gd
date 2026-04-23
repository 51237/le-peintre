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

var current_color = PaintColor.RED
var time_limit = 3.0
var time_left = 3.0
var is_active = false

signal combo_success(color)
signal combo_fail

func start_attack(color: PaintColor):
	current_color = color
	time_left = time_limit
	is_active = true

func check_input(pressed_buttons: Array) -> bool:
	var expected = COLOR_COMBOS[current_color]
	if pressed_buttons.size() == expected.size():
		for btn in expected:
			if btn not in pressed_buttons:
				return false
		return true
	return false

func get_color() -> Color:
	match current_color:
		PaintColor.RED:    return Color(1, 0, 0)
		PaintColor.BLUE:   return Color(0, 0, 1)
		PaintColor.GREEN:  return Color(0, 1, 0)
		PaintColor.PURPLE: return Color(0.5, 0, 0.5)
		PaintColor.CYAN:   return Color(0, 1, 1)
		PaintColor.YELLOW: return Color(1, 1, 0)
	return Color(1, 1, 1)

func _process(delta):
	if is_active:
		time_left -= delta
		if time_left <= 0:
			is_active = false
			emit_signal("combo_fail")
