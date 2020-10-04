# Default behaviour for a damage enemy melee object
# Deals damage to all enemies once and applies knockback
extends DamageEnemy
class_name DefaultMelee

# Keep track of objects that have already been hit by this object
var _obj_hit = []

# If weapon is invisible, destroy melee object since it belongs to the weapon
func _physics_process(delta):
	if !get_parent().visible:
		queue_free()

func _on_hit(other):
	if not _obj_hit.has(other) and other.get_owner().is_in_group("enemies"):
		_obj_hit.append(other)
		print("meleed enemy, knockback")
