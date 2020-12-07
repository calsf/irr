extends Weapon
class_name Shortbow

var Melee = preload("res://weapons/shortbow/ShortbowMelee.tscn")
var Empowered = preload("res://weapons/shortbow/ShortbowEmpowered.tscn")

# Spawn normal damage object in attack animation
# Attack speed is based on animation
func spawn_normal():
	spawn_melee_basic(Melee)

# Spawn empowered damage object in attack animation
# Attack speed is based on animation
func spawn_empow():
	spawn_melee_basic(Empowered)
