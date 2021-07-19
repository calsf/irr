extends KinematicBody2D


export var proj_path_norm : String
onready var NormProj = load(proj_path_norm)

onready var _spawn_pos = $Body/Attack/SpawnPos

var _random = RandomNumberGenerator.new()

# Shoot projectile in random direction
func _attack_random():
	_random.randomize()
	var x = _random.randf_range(-10, 10)
	var y = _random.randf_range(-10, 10)
	
	var obj = NormProj.instance()
	get_tree().get_root().add_child(obj)
	obj.global_position = _spawn_pos.global_position
	obj.dir = Vector2(x, y).normalized()
