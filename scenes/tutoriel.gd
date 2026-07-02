extends CanvasLayer

@onready var label = $Panel/Label

var etape = 0

var textes = [
	"Bienvenue !\nAvant de commencer, apprends à jouer d'abord, suis ce que je vais dire.",
	"Tout d'abord, vérifie que la manette est bien connectée pour pouvoir jouer (palette de peinture), le clavier n'est pas disponible pour le moment.",
	"Le bouton en bas à droite, c'est l'attaque de base.",
	"Les trois boutons en haut de la manette se sont les attaques aussi,\nmais observe bien les LED et le méchant tableau à l'écran car ils te disent les couleurs et les LED s'allument dans la couleur\nmais c'est aléatoire donc tu dois appuyer en fonction de la couleur et de la LED.",
	"Tu as la possibilité de faire un coup spécial. Tu verras en bas à droite, juste en dessous de ta vie de l'écran,\ntu as une barre et quand elle est à 100 % (rechargeable qu'en mettant des dégâts au tableau), \ntu peux appuyer sur les trois boutons en même temps pour lui faire plus de dégâts.",
	"Tu as la photorésistance entre le bouton pour les attaques de base et les trois boutons\n, tu peux le cacher avec ta main ou autre pour faire des esquives,\attention utilise le bien.\nc'est un capteur de lumière.",
    "J'espère que tu connais bien les mélanges de couleurs,\nje te laisse voir par toi-même. Regarde bien les LED et les couleurs à l'écran."
]

func _ready():
	label.text = textes[0]
	
func _on_suivantbtn_pressed() -> void:
	etape += 1
	
	if etape < textes.size():
		label.text = textes[etape]
	else:
		hide()
