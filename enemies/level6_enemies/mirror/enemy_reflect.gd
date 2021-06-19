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
		other.get_owner().dir = (global_position - other.get_owner().dir).normalized()
