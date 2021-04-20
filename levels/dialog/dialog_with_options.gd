extends DialogBox
class_name DialogWithOptions

onready var _dialog_options = $DialogOptions
onready var _ok1 = $DialogOptions/Ok1
onready var _ok2 = $DialogOptions/Ok2

# Called when the node enters the scene tree for the first time.
func _ready():
	_dialog_options.visible = false
	
	# Pressing on dialog options should exit dialog
	_ok1.connect("pressed", self, "_exit_dialog")
	_ok2.connect("pressed", self, "_exit_dialog")	

# At end of dialog, show dialog options and make arrow invisible
func _end_of_dialog():
	_dialog_options.visible = true
	_arrow.visible = false
	_can_go_next = false	# To disable button press sound, only play when press option

# Override _exit_dialog, exit and reset dialog and play button pressed sound
func _exit_dialog():
	_dialog.text = ""
	_curr_msg = ""
	_curr_char = 0
	_msg_index = 0
	_arrow.visible = false
	is_active = false
	_anim.play("close")
	_sounds.play("ButtonPressed")
