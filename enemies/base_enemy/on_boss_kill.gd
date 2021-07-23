extends Node

const EXIT_POSITION = Vector2(0, -96)

var chest_path = "res://levels/chest/WeaponChest.tscn"
onready var ChestObject = load(chest_path)

export var exit_path = "res://levels/components/interactable_portals/ExitPortal.tscn"
onready var ExitObject = load(exit_path)

# Spawns chest object at position
func spawn_chest(position):
	var obj = ChestObject.instance()
	get_tree().current_scene.add_child(obj)
	obj.global_position = position

# Spawns exit portal at position
# Exit portal is responsible for marking level as completed and saving
# level_completed is name of the setting to set as true in SaveLoadManager
func spawn_exit_portal(level_completed):
	var obj = ExitObject.instance()
	get_tree().current_scene.add_child(obj)
	obj.global_position = EXIT_POSITION
	obj.level_completed = level_completed
