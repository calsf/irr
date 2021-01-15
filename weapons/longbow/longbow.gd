extends Weapon
class_name Longbow

var Melee = preload("res://weapons/longbow/LongbowMelee.tscn")
var Empowered = preload("res://weapons/longbow/LongbowEmpowered.tscn")

onready var player = get_tree().current_scene.get_node("Player")
onready var emp_spawn_pos = $Sprite/SpawnPosEmp

# Spawn normal damage object in attack animation
# Attack speed is based on animation
func spawn_normal():
	spawn_melee_basic(Melee)

# Spawn empowered damage object in attack animation
# Attack speed is based on animation
func spawn_empow():
	var emp = Empowered.instance()
	add_child(emp)
	emp.global_position = emp_spawn_pos.global_position
	emp.rotation_degrees = _rot + 90
	var emp_sprite = emp.get_node("Sprite")
	emp_sprite.scale.x = _sprite.scale.x
