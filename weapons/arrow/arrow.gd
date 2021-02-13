extends Weapon
class_name Arrow

var Melee = preload("res://weapons/arrow/ArrowMelee.tscn")
var Empowered = preload("res://weapons/arrow/ArrowEmpowered.tscn")

# Spawn normal damage object in attack animation
# Attack speed is based on animation
func spawn_normal():
	spawn_melee_basic(Melee)

# Spawn empowered damage object in attack animation
# Attack speed is based on animation
func spawn_empow():
	spawn_melee_basic(Empowered)
