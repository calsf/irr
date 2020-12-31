extends Control
class_name DialogBox

const CHAR_DELAY = .03
const POS_OFFSET =  Vector2(158, 21)

# The series of messages to be shown through this dialog box
export var messages: Array

# Path to texture for speaker icon
export var img_path : String

onready var _dialog = $Dialog
onready var _timer = $TextTimer
onready var _img = $SpeakerTexture
onready var _anim = $AnimationPlayer

var is_active = false
var _msg_index = 0	# Current message of messages
var _curr_msg = ""	# The entire message that is currently written
var _curr_char = 0	# The curr char of the message to be written
var cam = null

signal dialog_finished()

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_mode = PAUSE_MODE_PROCESS # Never pause dialog box functionality
	
	cam = get_tree().current_scene.get_node("Camera2D")
	
	# Init scale to 0 so anim doesn't flicker when dialog is activated and open anim is played
	self.rect_scale = Vector2.ZERO
	
	# When timer runs out, write the next character in the current message
	_timer.connect("timeout", self, "_write_next_char")
	
	_anim.connect("animation_finished", self, "_on_anim_finish")
	
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
				_anim.play("close")
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
	# Move dialog to camera position and offset by POS_OFFSET
	rect_position = cam.global_position + POS_OFFSET
	_anim.play("open")

# Writes the next character in current message
func _write_next_char():
	if is_active and _dialog.text != messages[_msg_index] and _curr_msg.length() < messages[_msg_index].length():
		_curr_msg = _curr_msg + messages[_msg_index][_curr_char]
		_dialog.text = _curr_msg
		_curr_char += 1
		_timer.start(CHAR_DELAY)

# Start writing after open anim, finish dialog after close anim
func _on_anim_finish(anim):
	if anim == "open":
		_timer.start(CHAR_DELAY)
	elif anim == "close":
		self.visible = false
		get_tree().paused = false
		emit_signal("dialog_finished")
	
