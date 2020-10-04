# Default behaviour for a damage enemy ranged object
# Destroyed upon hitting enemy or terrain, deals damage to enemy
extends DamageEnemy
class_name DefaultRanged

func _on_hit(other):
	if other.get_owner().is_in_group("enemies"):
		print("hit enemy")
		queue_free()
	else:
		queue_free()
