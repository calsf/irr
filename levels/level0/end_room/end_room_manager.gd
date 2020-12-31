extends Node

var player = null
var room_id = -1

onready var _dialog_start = $DialogContainer/DialogBoxStart

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().current_scene.get_node("Player")
	player.connect("entered_room", self, "_on_entry")
	
	# Let player resume action after start dialog is finished
	_dialog_start.connect("dialog_finished", self, "_resume_action")
	
	# Owner should be the room this object belongs to
	room_id = get_owner().room_id

# On entry, pause player action, let animations play, then prompt dialog
# After dialog is finished, it should resume player action
func _on_entry(entered_room_id):
	if entered_room_id == room_id:
		player.stop_player()
		
		# Wait for end room animations to finish then activate start dialog
		yield(get_tree().create_timer(2), "timeout")
		_dialog_start.activate_dialog()

# Allow player to act again
func _resume_action():
	player.can_act = true
		
