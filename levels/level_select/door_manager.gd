extends Node

onready var _save_data = SaveLoadManager.load_data()
onready var _recommended = $RecommendedLabel

var _doors = []
var _recommended_door = null
var _levels = [
	"level1_completed",
	"level2_completed",
	"level3_completed",
	"level4_completed",
	"level5_completed",
	"level6_completed"
]

var game_completed = "level7_completed"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Doors should be ordered from levels 1 to 7
	_doors = $Doors.get_children()
	
	if not _save_data[_levels[0]]:
		_recommended_door = _doors[0]
	elif not _save_data[_levels[1]]:
		_recommended_door = _doors[1]
	elif not _save_data[_levels[2]]:
		_recommended_door = _doors[2]
	elif not _save_data[_levels[3]]:
		_recommended_door = _doors[3]
	elif not _save_data[_levels[4]]:
		_recommended_door = _doors[4]
	elif not _save_data[_levels[5]]:
		_recommended_door = _doors[5]
	else:
		_recommended_door = _doors[6]
	
	# If game not completed, don't allow re-entry to completed levels
	if !_save_data[game_completed]:
		# If level is completed, shut off player access to the door to level
		for i in range(0, _levels.size()):
			if _save_data[_levels[i]]:
				_doors[i].get_node("InteractArea/CollisionShape2D").disabled = true
		
		# Only show recommended door when player has not completed game
		_recommended.global_position = _recommended_door.global_position
	else:	# Do not disable doors if game has been completed
		# Also remove recommended if game completed
		_recommended.queue_free()
	
