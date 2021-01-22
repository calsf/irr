extends Weapon
class_name Sword

var Projectile = preload("res://weapons/sword/SwordProjectile.tscn")
var Empowered = preload("res://weapons/sword/SwordEmpowered.tscn")

# Spawn normal damage object in attack animation
# Attack speed is based on animation
func spawn_normal():
	spawn_range_basic(Projectile)

# Spawn empowered damage object in attack animation
# Attack speed is based on animation
func spawn_empow():
	var emp = Empowered.instance()
	get_tree().current_scene.add_child(emp)
	emp.global_position = get_global_mouse_position()
