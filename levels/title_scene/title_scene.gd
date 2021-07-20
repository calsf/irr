extends Node2D

const LEVEL_SELECT = "res://levels/level_select/LevelSelect.tscn"
const LEVEL0 = "res://levels/level0/Level0.tscn"

onready var _fade = $CanvasLayer/Fade
onready var _continue_btn = $CanvasLayer/Options/Continue
onready var _new_game_btn = $CanvasLayer/Options/NewGame
onready var _warning_prompt = $CanvasLayer/WarningPrompt
onready var _confirm_btn = $CanvasLayer/WarningPrompt/Confirm
onready var _cancel_btn = $CanvasLayer/WarningPrompt/Cancel

# Called when the node enters the scene tree for the first time.
func _ready():
	# Disable continue btn if no save file exists
	if SaveLoadManager.check_save():
		_continue_btn.disabled = false
	else:
		_continue_btn.disabled = true
	
	_warning_prompt.visible = false
	_continue_btn.connect("pressed", self, "_on_continue")
	_new_game_btn.connect("pressed", self, "_on_new_game")
	_confirm_btn.connect("pressed", self, "_on_confirm")
	_cancel_btn.connect("pressed", self, "_on_cancel")

# Load level 0 or level select depending on player's saved progress
func _on_continue():
	var save_data = SaveLoadManager.load_data()
	if save_data["finished_level0"]:
		_fade.go_to_scene(LEVEL_SELECT)
	else:
		_fade.go_to_scene(LEVEL0)
	
	GlobalSounds.play("ButtonPressed")

# Show warning prompt, disable options from being able to be clicked on
func _on_new_game():
	# Skip warning if no existing save to overwrite
	if not SaveLoadManager.check_save():
		_on_confirm()
		return

	_continue_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_new_game_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_warning_prompt.visible = true
	
	GlobalSounds.play("ButtonPressed")

# Confirm new game
func _on_confirm():
	_confirm_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cancel_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	SaveLoadManager.reset_data()
	_fade.go_to_scene(LEVEL0)
	
	GlobalSounds.play("ButtonPressed")

# Cancel new game, hide prompt and allow options to be clicked on again
func _on_cancel():
	_continue_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_new_game_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_warning_prompt.visible = false
	
	GlobalSounds.play("ButtonPressed")
