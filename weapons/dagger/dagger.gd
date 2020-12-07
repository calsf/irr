extends Weapon
class_name Dagger

var Projectile = preload("res://weapons/dagger/DaggerProjectile.tscn")
var Empowered = preload("res://weapons/dagger/DaggerEmpowered.tscn")

# Spawn normal damage object in attack animation
# Attack speed is based on animation
func spawn_normal():
	spawn_range_basic(Projectile)

# Spawn empowered damage object in attack animation
# Attack speed is based on animation
func spawn_empow():
	spawn_range_basic(Empowered)
