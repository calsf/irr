extends Weapon
class_name Book

var Projectile = preload("res://weapons/book/BookProjectile.tscn")
var Empowered = preload("res://weapons/book/BookEmpowered.tscn")

# Spawn normal damage object in attack animation
# Attack speed is based on animation
func spawn_normal():
	spawn_range_basic(Projectile)

# Spawn empowered damage object in attack animation
# Attack speed is based on animation
func spawn_empow():
	spawn_range_basic(Empowered)

