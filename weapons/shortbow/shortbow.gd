extends Weapon
class_name Shortbow

var Melee = preload("res://weapons/shortbow/ShortbowMelee.tscn")

# Spawn normal damage object in attack animation
# Attack speed is based on animation
func spawn_normal():
	spawn_melee_normal(Melee)

# Spawn empowered damage object in attack animation
# Attack speed is based on animation
func spawn_empow():
	pass
