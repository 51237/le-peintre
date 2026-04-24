extends CanvasLayer

const COLOR_NAMES = {
	0: "ROUGE",
	1: "BLEU",
	2: "VERT",
	3: "VIOLET",
	4: "CYAN",
	5: "JAUNE"
}

const COLOR_VALUES = {
	0: Color(1.0, 0.0, 0.0, 1.0),
	1: Color(0.0, 0.0, 1.0, 1.0),
	2: Color(0.0, 1.0, 0.0, 1.0), 
	3: Color(1.0, 0.0, 1.0, 1.0),
	4: Color(0.0, 1.0, 1.0, 1.0),
	5: Color(0.949, 1.0, 0.0, 1.0)
}

var color_mechanic
var player

func _ready():
	color_mechanic = get_node("../ColorMechanic")
	player = get_node("../Player")
	color_mechanic.combo_success.connect(_on_success)
	color_mechanic.combo_fail.connect(_on_fail)
	$ColorTarget.visible = false  # ← ici
	$AttackLabel.visible = false  # ← ici
	print("UI prêt - noeuds trouvés : ", color_mechanic, player)

func format_number(n: int) -> String:
	var s = str(n)
	var result = ""
	var count = 0
	for i in range(s.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = " " + result
		result = s[i] + result
		count += 1
	return result

func _process(_delta):
	if color_mechanic == null or player == null:
		return

	# Timer et couleur demandée
	if color_mechanic.is_active:
		var ratio = color_mechanic.time_left / color_mechanic.time_limit
		$TimerBar.value = ratio * 100
		var c = color_mechanic.current_color
		# $AttackLabel.text = "Couleur : " + COLOR_NAMES[c]  # ← commenter
		# $ColorTarget.color = COLOR_VALUES[c]               # ← commenter
	else:
		$TimerBar.value = 0
		# $AttackLabel.text = "..."        # ← commenter
		# $ColorTarget.color = Color(0.2, 0.2, 0.2)  # ← commenter

	# Barres de vie
	$PlayerLife.value = player.health
	$BossLife.value = player.boss_health
	$BossLife.show_percentage = false
	$BossHPLabel.text = format_number(player.boss_health) + " / 1 000 000"

	# Barre spéciale
	$SpecialBar.value = player.special_charge

func _on_success(_color):
	$AttackLabel.text = "BIEN JOUE !"

func _on_fail():
	$AttackLabel.text = "AÏÏE !"
