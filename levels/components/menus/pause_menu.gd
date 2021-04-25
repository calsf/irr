extends Control

# Path to the scene to quit to
export var quit_to_scene : String

onready var _resume_btn = $Buttons/Resume
onready var _sound_btn = $Buttons/Sound
onready var _quit_btn = $Buttons/Quit
onready var _fade = get_tree().current_scene.get_node("CanvasLayer/Fade")

var player_obj = null
var menu_paused = false	# If pause menu is what triggered pause

var _save_data = SaveLoadManager.load_data()

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS	# This will never pause
	_resume_btn.connect("pressed", self, "_resume")
	_sound_btn.connect("pressed", self, "_toggle_sound")
	_quit_btn.connect("pressed", self, "_quit")
	
	# Get reference to player object
	player_obj = get_tree().current_scene.get_node("Player")
	
	# Init sound button text based on saved data and set pause invisible
	if _save_data["sound_muted"]:
		_sound_btn.text = "Sound: OFF"
	else:
		_sound_btn.text = "Sound: ON"
	visible = false

func _input(event):
	# Pause/unpause input
	if event.is_action_pressed("pause") and player_obj.can_act:
		if not get_tree().paused:
			menu_paused = true
			get_tree().paused = true
			visible = true
		elif menu_paused and get_tree().paused:
			menu_paused = false
			get_tree().paused = false
			visible = false

# Unpause, for when button is pressed
func _resume():
	# NOTE:
	# The sound must be in proccess pause mode or else it won't play due to pause
	GlobalSounds.play("ButtonPressed")
	
	menu_paused = false
	get_tree().paused = false
	visible = false

# Toggle sound on/off
func _toggle_sound():
	_save_data = SaveLoadManager.load_data()
	if _save_data["sound_muted"]:
		_save_data["sound_muted"] = false
		_sound_btn.text = "Sound: ON"
		SaveLoadManager.save_data(_save_data)
		GlobalSounds.play("ButtonPressed")
	else:
		_save_data["sound_muted"] = true
		_sound_btn.text = "Sound: OFF"
		SaveLoadManager.save_data(_save_data)

# Go to scene as specified by the quit_to_scene path
func _quit():
	GlobalSounds.play("ButtonPressed")
	visible = false
	_fade.go_to_scene(quit_to_scene)
