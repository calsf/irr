extends Enemy
class_name EnemyReflect

onready var _atk_anim = $Body/Attack/AttackAnimation

func _ready():
	# For detecting other enemy projectiles only
	$Hitbox.connect("area_entered", self, "_on_hit")
	$Hitbox.connect("body_entered", self, "_on_hit")

# Reflect other enemy projectiles if they hit this enemy
func _on_hit(other):
	# Must be a DamagePlayer object to reflect
	if other.get_owner() is DamagePlayer and other.get_owner().get_speed() > 0:
		_atk_anim.play("attack")
		var last_dir = other.get_owner().dir
		var new_dir = (global_position - other.get_owner().global_position).normalized()
		
		# Adjust y direction of projectile if it didn't change
		# Does not work with projectiles that have a 0 value for y
		if (sign(new_dir.y) == sign(last_dir.y)):
			new_dir.y = -new_dir.y
		
		other.get_owner().dir = new_dir
