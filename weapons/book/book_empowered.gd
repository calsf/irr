# Empowered book acts like a normal projectile but spawns projectiles from itself
extends DamageEnemy
class_name BookEmpowered

const DIR = [
	Vector2(1, 1),
	Vector2(1, -1),
	Vector2(-1, -1),
	Vector2(-1, 1),
	
	Vector2(1, 0),
	Vector2(-1, 0),
	Vector2(0, 1),
	Vector2(0, -1),
	
]

var Projectile = preload("res://weapons/book/BookEmpProjectile.tscn")

onready var _spawn_pos = $Sprite/SpawnPos

func _on_hit(other):
	if other.get_owner().is_in_group("enemies"):
		_add_meter()
		other.get_owner().update_health(-_damage)
		
		# Apply knockback based on pos on hit, most projectiles should have 0 _knockback
		var initial_dir = other.global_position - global_position
		other.get_owner().apply_knockback(initial_dir, _knockback)
		
		queue_free()
	else:
		queue_free()

func _spawn_projectile():
	for direction in DIR:
		var proj = Projectile.instance()
		get_tree().current_scene.add_child(proj)
		proj.global_position = _spawn_pos.global_position
		proj.dir = direction.normalized()
		proj._speed *= 2
