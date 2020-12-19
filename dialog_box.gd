extends Control
class_name DialogBox

const CHAR_DELAY = .06

# The series of messages to be shown through this dialog box
export var messages: Array

# Path to texture for speaker icon
export var img_path : String

onready var _dialog = $Dialog
onready var _timer = $TextTimer
onready var _img = $SpeakerTexture

var is_active = false
var _msg_index = 0	# Current message of messages
var _curr_msg = ""	# The entire message that is currently written
var _curr_char = 0	# The curr char of the message to be written

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_mode = PAUSE_MODE_PROCESS # Never pause dialog box functionality
	
	# When timer runs out, write the next character in the current message
	_timer.connect("timeout", self, "_write_next_char")
	
	# Initialize dialog box
	_dialog.text = ""
	_img.texture = load(img_path)
	self.visible = false

func _input(event):
	# Only listen for input if this dialog box is activated
	if is_active and Input.is_action_pressed("normal_attack"):
		# Load the entire current message if it is not written out entirely yet
		if _dialog.text != messages[_msg_index]:
				_dialog.text = messages[_msg_index]
		else:
			# If messages have all be shown, exit out of dialog box and unpause
			if _msg_index + 1 > messages.size() - 1:
				is_active = false
				self.visible = false
				get_tree().paused = false
			else:	# Else, go to next message
				_dialog.text = ""
				_curr_msg = ""
				_curr_char = 0
				_msg_index += 1

# Show dialog box and start going through series of messages
func activate_dialog():
	is_active = true
	self.visible = true
	get_tree().paused = true
	_timer.start(CHAR_DELAY)

# Writes the next character in current message
func _write_next_char():
	if is_active and _dialog.text != messages[_msg_index] and _curr_msg.length() < messages[_msg_index].length():
		_curr_msg = _curr_msg + messages[_msg_index][_curr_char]
		_dialog.text = _curr_msg
		_curr_char += 1
		_timer.start(CHAR_DELAY)
