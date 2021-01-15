extends Weapon
class_name Staff

var Projectile = preload("res://weapons/staff/StaffProjectile.tscn")
var Empowered = preload("res://weapons/staff/StaffEmpowered.tscn")

# Spawn normal damage object in attack animation
# Attack speed is based on animation
func spawn_normal():
	spawn_range_basic(Projectile)

# Spawn empowered damage object in attack animation
# Attack speed is based on animation
func spawn_empow():
	spawn_range_basic(Empowered)
