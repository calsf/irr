extends Node

export var proj_path : String

onready var Projectile = load(proj_path)
onready var _spawn_pos = $SpawnPos

func _shoot(dir):
	var proj = Projectile.instance()
	proj.scale = get_owner().scale
	get_tree().get_root().add_child(proj)
	proj.global_position = _spawn_pos.global_position
	proj.dir = dir
