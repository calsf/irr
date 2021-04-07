# Same as default ranged but DOES NOT queue free when hits enemy
# Only destroyed when it hits terrain
extends DamageEnemy
class_name StaffProjectile

func _on_hit(other):
	if other.get_owner().is_in_group("enemies"):
		_add_meter()
		other.get_owner().update_health(-_damage)
		
		# Apply knockback based on pos on hit, most projectiles should have 0 _knockback
		var initial_dir = other.global_position - global_position
		other.get_owner().apply_knockback(initial_dir, _knockback)
	elif not other.is_in_group("enemies"):
		queue_free()

