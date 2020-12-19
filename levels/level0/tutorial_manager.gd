extends Node

var player

onready var _dialog = $DialogContainer/DialogBox
onready var _room = get_parent()
onready var save_data = SaveLoadManager.load_data()

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().current_scene.get_node("Player")
	
	# Starts tutorial after player's start/entrance animation has finished
	player.connect("has_started", self, "_start_tutorial")
	
	# Lock starting room if tutorial has not been completed
	if not save_data["finished_tutorial"]:
		_room.is_locked = true
		_room.room_solved = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Check if player has completed tutorial, if not start tutorial
func _start_tutorial():
	if not save_data["finished_tutorial"]:
		_dialog.activate_dialog()

