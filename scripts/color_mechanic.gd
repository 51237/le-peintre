extends Node

# Les couleurs possibles que le boss peut demander
enum PaintColor { RED, BLUE, YELLOW, PURPLE, ORANGE, GREEN }

# Quelle combinaison de boutons correspond à quelle couleur
const COLOR_COMBOS = {
	PaintColor.RED:    [0],       # bouton rouge seul
	PaintColor.BLUE:   [1],       # bouton bleu seul
	PaintColor.YELLOW: [2],       # bouton jaune seul vert
	PaintColor.PURPLE: [0, 1],   # rouge + bleu
	PaintColor.ORANGE: [0, 2],   # rouge + jaune
	PaintColor.GREEN:  [1, 2],   # bleu + jaune violet jaune cyan
}

var current_color = PaintColor.RED
var time_limit = 3.0   # secondes pour répondre
var time_left = 3.0
var is_active = false

signal combo_success(color)
signal combo_fail

func start_attack(color : PaintColor):
	current_color = color
	time_left = time_limit
	is_active = true

func check_input(pressed_buttons: Array) -> bool:
	var expected = COLOR_COMBOS[current_color]
	# Vérifie que les boutons pressés correspondent exactement
	if pressed_buttons.size() == expected.size():
		for btn in expected:
			if btn not in pressed_buttons:
				return false
		return true
	return false
	
func is_combo_color() -> bool:
	return current_color in [PaintColor.PURPLE, PaintColor.ORANGE, PaintColor.GREEN]

func get_shield_color() -> Color:
	match current_color:
		PaintColor.PURPLE: return Color(0.5, 0, 0.5)
		PaintColor.ORANGE: return Color(1, 0.5, 0)
		PaintColor.GREEN:  return Color(0, 1, 0)
	return Color(1, 1, 1)

func _process(delta):
	if not is_active:
		return
	time_left -= delta
	if time_left <= 0:
		is_active = false
		emit_signal("combo_fail")
