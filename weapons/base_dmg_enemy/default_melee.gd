# Default behaviour for a damage enemy melee object
# Deals damage to all enemies once and applies knockback
extends DamageEnemy
class_name DefaultMelee

# Keep track of objects that have already been hit by this object
var _obj_hit = []
var initial_dir = Vector2.ZERO

func _ready():
	# Player mouse may move after meleeing
	# Get initial direction of mouse so knockback vector is accurate
	initial_dir = get_global_mouse_position() - global_position

# If weapon is invisible, destroy melee object since it belongs to the weapon
func _physics_process(delta):
	if !get_parent().visible:
		queue_free()

func _on_hit(other):
	if not _obj_hit.has(other) and other.get_owner().is_in_group("enemies"):
		_obj_hit.append(other)
		_add_meter()
		other.get_owner().update_health(-_damage)
		
		# Melees will apply knockback
		other.get_owner().apply_knockback(initial_dir, _knockback)

# Reset list of hit objects
func _reset_obj_hit():
	_obj_hit.clear()
