extends Node2D

# Array of paths to enemy objects that can be spawned
export var enemies : Array
var enemy = null

func _ready():
	GlobalSounds.play_enemy_spawn()

# Spawn enemy at this position under the room's Enemies node
# Assumes EnemySpawn object is in the Enemies node and the Room is its owner
func _spawn_enemy():
	randomize()
	var selected_enemy = enemies[randi() % enemies.size()]
	var enemy_obj = load(selected_enemy)
	enemy = enemy_obj.instance()
	get_parent().add_child(enemy)
	enemy.global_position = global_position
	_call_aggro_check()

# Check for aggro
func _call_aggro_check():
	enemy.check_aggro(-1)
