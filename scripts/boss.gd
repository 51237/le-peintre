extends Node2D

var color_mechanic

func _ready():
	color_mechanic = get_node("../ColorMechanic")
	# Lance une attaque toutes les 4 secondes
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 4.0
	timer.autostart = true
	timer.timeout.connect(_launch_attack)
	timer.start()

func _launch_attack():
	# Choisit une couleur au hasard parmi les 6
	var random_color = randi() % 6
	color_mechanic.start_attack(random_color)
	print("Boss attaque avec la couleur : ", random_color)
