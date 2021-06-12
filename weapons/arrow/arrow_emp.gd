# Deals damage to all enemies once and applies knockback, also destroys projectiles
extends DamageEnemy
class_name ArrowEmp

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

# Collision mask will collide with enemy projectiles
# Projectile will have its on_hit triggered when colliding with emp attack
func _on_hit(other):
	if not _obj_hit.has(other) and other.get_owner().is_in_group("enemies"):
			_obj_hit.append(other)
			other.get_owner().update_health(-_damage)
			
			# Melees will apply knockback
			other.get_owner().apply_knockback(initial_dir, _knockback)
