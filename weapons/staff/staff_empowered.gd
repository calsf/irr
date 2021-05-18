extends DamageEnemy
class_name StaffEmpowered

var returning = false
var player_obj = null

func _ready():
	# Get reference to player object
	player_obj = get_tree().current_scene.get_node("Player")

func _on_hit(other):
	if other.get_owner().is_in_group("enemies"):
		_add_meter()
		other.get_owner().update_health(-_damage)
		
		# Apply knockback based on pos on hit, most projectiles should have 0 _knockback
		var initial_dir = other.global_position - global_position
		other.get_owner().apply_knockback(initial_dir, _knockback)
	elif not other.is_in_group("enemies"):
		if not returning:
			returning = true

func _move(delta):
	if returning:
		dir = (player_obj.global_position - global_position).normalized()
		if global_position.distance_to(player_obj.global_position) < 10:
			queue_free()
	
	position += (dir * _speed) * delta
		
