extends CanvasLayer

# Noms des couleurs pour l'affichage
const COLOR_NAMES = {
	0: "ROUGE",
	1: "BLEU",
	2: "JAUNE",
	3: "VIOLET",
	4: "ORANGE",
	5: "VERT"
}

# Couleurs visuelles correspondantes
const COLOR_VALUES = {
	0: Color(0.85, 0.2, 0.2),
	1: Color(0.2, 0.4, 0.85),
	2: Color(0.95, 0.85, 0.1),
	3: Color(0.6, 0.2, 0.85),
	4: Color(0.95, 0.5, 0.1),
	5: Color(0.2, 0.75, 0.3)
}

var color_mechanic
var player

func _ready():
	color_mechanic = get_node("../ColorMechanic")
	player = get_node("../Player")
	
	# Connecte les signaux
	color_mechanic.combo_success.connect(_on_success)
	color_mechanic.combo_fail.connect(_on_fail)

func _process(_delta):
	# Met à jour le timer visuel
	if color_mechanic.is_active:
		var ratio = color_mechanic.time_left / color_mechanic.time_limit
		$TimerBar.value = ratio * 100
	else:
		$TimerBar.value = 0
	
	# Met à jour la couleur demandée
	if color_mechanic.is_active:
		var c = color_mechanic.current_color
		$AttackLabel.text = "Couleur : " + COLOR_NAMES[c]
		$ColorTarget.color = COLOR_VALUES[c]
	else:
		$AttackLabel.text = "..."
		$ColorTarget.color = Color(0.2, 0.2, 0.2)
	
	# Met à jour les barres de vie
	$PlayerLife.value = player.health
	$BossLife.value = player.boss_health

func _on_success(_color):
	$AttackLabel.text = "✅ BIEN JOUÉ !"

func _on_fail():
	$AttackLabel.text = "❌ AÏÏE !"
