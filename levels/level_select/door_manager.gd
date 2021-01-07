extends Node

onready var _save_data = SaveLoadManager.load_data()
onready var _recommended = $RecommendedLabel

var _doors = []
var _recommended_door = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# Doors should be ordered from levels 1 to 7
	_doors = $Doors.get_children()
	
	if not _save_data["level1_completed"]:
		_recommended_door = _doors[0]
	elif not _save_data["level2_completed"]:
		_recommended_door = _doors[1]
	elif not _save_data["level3_completed"]:
		_recommended_door = _doors[2]
	elif not _save_data["level4_completed"]:
		_recommended_door = _doors[3]
	elif not _save_data["level5_completed"]:
		_recommended_door = _doors[4]
	elif not _save_data["level6_completed"]:
		_recommended_door = _doors[5]
	else:
		_recommended_door = _doors[6]
	
	_recommended.global_position = _recommended_door.global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
