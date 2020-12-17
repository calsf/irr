extends Area2D

const INVULN_TIME = 1

onready var hurt_timer = $HurtTimer

var is_invuln = false

signal player_hurt()
signal invuln_finished()

func _physics_process(delta):
	# If not invulnerable, check for overlapping areas
	# If has any overlapping areas, deal damage to player and start invuln time
	# Must make sure collision mask is set to layers that will damage player
	# EnemyProjectile, DamagePlayer layers should hurt player
	if not is_invuln:
		var overlapping_areas = get_overlapping_areas()
		
		if overlapping_areas:
			# Check if any of the overlapping areas may damage player
			for area in overlapping_areas:
				if area.get_collision_layer():
					is_invuln = true
					PlayerHealth.lose_health(1)
					emit_signal("player_hurt")
					hurt_timer.start(INVULN_TIME)
					return

# When hurt timer runs out, player can take damage again
func _on_HurtTimer_timeout():
	is_invuln = false
	emit_signal("invuln_finished")
