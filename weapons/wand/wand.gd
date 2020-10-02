extends Weapon
class_name Wand

var Projectile = preload("res://weapons/wand/WandProjectile.tscn")

# Spawn normal damage object in attack animation
# Attack speed is based on animation
func spawn_normal():
	spawn_range_normal(Projectile)

# Spawn empowered damage object in attack animation
# Attack speed is based on animation
func spawn_empow():
	pass
