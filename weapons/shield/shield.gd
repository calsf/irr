extends Weapon
class_name Shield

var Projectile = preload("res://weapons/shield/ShieldProjectile.tscn")
var Empowered = preload("res://weapons/shield/ShieldEmpowered.tscn")

# Spawn normal damage object in attack animation
# Attack speed is based on animation
func spawn_normal():
	# Do not spawn on top of terrain
	var overlapping_terrain = \
			get_world_2d().direct_space_state.intersect_point(get_global_mouse_position(), 1, [], 1)
	if overlapping_terrain:
		return
		
	var proj = Projectile.instance()
	get_tree().current_scene.add_child(proj)
	proj.global_position = get_global_mouse_position()

# Spawn empowered damage object in attack animation
# Attack speed is based on animation
func spawn_empow():
	# Do not spawn on top of terrain
	# Will not spawn unless there is 48px of room for the lightning storm
	# Check approx half of 48px left and right of mouse position to ensure there is enough room
	var mouse_pos = get_global_mouse_position()
	var overlapping_terrain = \
			get_world_2d().direct_space_state.intersect_point(mouse_pos, 1, [], 1)
	var overlapping_terrain_left = \
			get_world_2d().direct_space_state.intersect_point(mouse_pos + Vector2(22, 0), 1, [], 1)
	var overlapping_terrain_right = \
			get_world_2d().direct_space_state.intersect_point(mouse_pos + Vector2(-22, 0), 1, [], 1)
	# If cannot be cast due to overlapping terrain, REFUND METER
	if overlapping_terrain or overlapping_terrain_left or overlapping_terrain_right:
		PlayerMeter.add_meter(weapon_props.empow_cost)
		return
		
	var emp = Empowered.instance()
	get_tree().current_scene.add_child(emp)
	emp.global_position = get_global_mouse_position()
