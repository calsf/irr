extends CanvasLayer

var player

onready var _dialog_start = $DialogContainer/DialogBoxStart
onready var _dialog_finish = $DialogContainer/DialogBoxFinish
onready var _room = get_parent()
onready var save_data = SaveLoadManager.load_data()

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().current_scene.get_node("Player")
	
	# Starts tutorial after player's start/entrance animation has finished
	player.connect("has_started", self, "_start_tutorial")
	
	# Check weapons everytime player swaps out
	# Tutorial is finished when both weapon slots are no longer empty
	player.connect("primary_swapped", self, "_check_weapons")
	player.connect("secondary_swapped", self, "_check_weapons")
	
	# Unlock room after last dialog
	_dialog_finish.connect("dialog_finished", self, "_unlock_start_room")
	
	# Lock starting room if tutorial has not been completed
	if not save_data["finished_tutorial"]:
		_room.is_locked = true
		_room.room_solved = false

# Check if player has completed tutorial, if not start tutorial
func _start_tutorial():
	if not save_data["finished_tutorial"]:
		_dialog_start.activate_dialog()
	else:
		queue_free()	# Can free tutorial manager if tutorial is completed

# Checks if 2 weapons have been picked, if so, tutorial is complete
func _check_weapons(_pickup_icon):
	if not save_data["finished_tutorial"]:
		save_data = SaveLoadManager.load_data()	# Reload data
	
		# Check if picked out two weapons, if so, player has completed tutorial so save data
		if save_data["primary_weapon_id"] > 1 and save_data["secondary_weapon_id"] > 1:
			save_data["finished_tutorial"] = true
			SaveLoadManager.save_data(save_data)
			_dialog_finish.activate_dialog()

# Unlock start room after player picks up 2 weapons and last dialog finishes
func _unlock_start_room():
	_room.room_solved = true
	
