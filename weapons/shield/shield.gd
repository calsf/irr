extends Weapon
class_name Shield

var Projectile = preload("res://weapons/shield/ShieldProjectile.tscn")
var Empowered = preload("res://weapons/shield/ShieldEmpowered.tscn")

# Spawn normal damage object in attack animation
# Attack speed is based on animation
func spawn_normal():
	var proj = Projectile.instance()
	get_tree().current_scene.add_child(proj)
	proj.global_position = get_global_mouse_position()

# Spawn empowered damage object in attack animation
# Attack speed is based on animation
func spawn_empow():
	var emp = Empowered.instance()
	get_tree().current_scene.add_child(emp)
	emp.global_position = get_global_mouse_position()
