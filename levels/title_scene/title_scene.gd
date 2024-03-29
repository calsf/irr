extends Node2D

const LEVEL_SELECT = "res://levels/level_select/LevelSelect.tscn"
const LEVEL0 = "res://levels/level0/Level0.tscn"

# Y position of hearts/text for difficulties
const HEARTS_Y_SELECTED = 21
const HEARTS_Y_UNSELECTED = 20
const TEXT_Y_SELECTED = 5
const TEXT_Y_UNSELECTED = 4

onready var _fade = $CanvasLayer/Fade
onready var _continue_btn = $CanvasLayer/Options/Continue
onready var _new_game_btn = $CanvasLayer/Options/NewGame
onready var _warning_prompt = $CanvasLayer/WarningPrompt
onready var _warning_confirm_btn = $CanvasLayer/WarningPrompt/WarningSelect/Confirm
onready var _warning_cancel_btn = $CanvasLayer/WarningPrompt/WarningSelect/Cancel
onready var _difficulty_prompt = $CanvasLayer/DifficultyPrompt
onready var _difficulty_confirm_btn = $CanvasLayer/DifficultyPrompt/DifficultyConfirm/Confirm
onready var _difficulty_cancel_btn = $CanvasLayer/DifficultyPrompt/DifficultyConfirm/Cancel

onready var _easy_btn = $CanvasLayer/DifficultyPrompt/DifficultySelect/Easy
onready var _norm_btn = $CanvasLayer/DifficultyPrompt/DifficultySelect/Normal
onready var _hard_btn = $CanvasLayer/DifficultyPrompt/DifficultySelect/Hard

onready var _easy_hearts = $CanvasLayer/DifficultyPrompt/DifficultySelect/Easy/Hearts
onready var _norm_hearts = $CanvasLayer/DifficultyPrompt/DifficultySelect/Normal/Hearts
onready var _hard_hearts = $CanvasLayer/DifficultyPrompt/DifficultySelect/Hard/Hearts

onready var _easy_text = $CanvasLayer/DifficultyPrompt/DifficultySelect/Easy/Text
onready var _norm_text = $CanvasLayer/DifficultyPrompt/DifficultySelect/Normal/Text
onready var _hard_text = $CanvasLayer/DifficultyPrompt/DifficultySelect/Hard/Text

var selected_difficulty
var _cursor = load("res://cursor.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set cursor on title load
	Input.set_custom_mouse_cursor(_cursor, 0, Vector2.ZERO)
	
	# Disable continue btn if no save file exists
	if SaveLoadManager.check_save():
		_continue_btn.disabled = false
	else:
		_continue_btn.disabled = true
	
	_difficulty_prompt.visible = false
	_warning_prompt.visible = false
	_continue_btn.connect("pressed", self, "_on_continue")
	_new_game_btn.connect("pressed", self, "_on_new_game")
	_warning_confirm_btn.connect("pressed", self, "_on_warning_confirm")
	_warning_cancel_btn.connect("pressed", self, "_on_warning_cancel")
	_difficulty_confirm_btn.connect("pressed", self, "_on_difficulty_confirm")
	_difficulty_cancel_btn.connect("pressed", self, "_on_difficulty_cancel")
	
	_easy_btn.connect("pressed", self, "_toggle_difficulty", [SaveLoadManager.DIFFICULTY.EASY])
	_norm_btn.connect("pressed", self, "_toggle_difficulty", [SaveLoadManager.DIFFICULTY.NORMAL])
	_hard_btn.connect("pressed", self, "_toggle_difficulty", [SaveLoadManager.DIFFICULTY.HARD])
	
	# Initialize difficulty
	selected_difficulty = SaveLoadManager.DIFFICULTY.NORMAL
	_easy_btn.pressed = false
	_norm_btn.pressed = true
	_hard_btn.pressed = false
	_norm_hearts.rect_position.y = HEARTS_Y_SELECTED
	_norm_text.rect_position.y = TEXT_Y_SELECTED

# Load level 0 or level select depending on player's saved progress
func _on_continue():
	var save_data = SaveLoadManager.load_data()
	if save_data["finished_level0"]:
		_fade.go_to_scene(LEVEL_SELECT)
	else:
		_fade.go_to_scene(LEVEL0)
	
	GlobalSounds.play("ButtonPressed")

# Attempt to create new game, first show difficulty prompt
func _on_new_game():
	_continue_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_new_game_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	_difficulty_prompt.visible = true
	_easy_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_norm_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_hard_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_difficulty_confirm_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_difficulty_cancel_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	
	GlobalSounds.play("ButtonPressed")

# Toggle difficulty when pressing a difficulty button
func _toggle_difficulty(difficulty):
	if difficulty == SaveLoadManager.DIFFICULTY.EASY:
			selected_difficulty = SaveLoadManager.DIFFICULTY.EASY
			_easy_btn.pressed = true
			_norm_btn.pressed = false
			_hard_btn.pressed = false
			
			_easy_hearts.rect_position.y = HEARTS_Y_SELECTED
			_easy_text.rect_position.y = TEXT_Y_SELECTED
			
			_norm_hearts.rect_position.y = HEARTS_Y_UNSELECTED
			_norm_text.rect_position.y = TEXT_Y_UNSELECTED
			
			_hard_hearts.rect_position.y = HEARTS_Y_UNSELECTED
			_hard_text.rect_position.y = TEXT_Y_UNSELECTED
	elif difficulty == SaveLoadManager.DIFFICULTY.NORMAL:
			selected_difficulty = SaveLoadManager.DIFFICULTY.NORMAL
			_easy_btn.pressed = false
			_norm_btn.pressed = true
			_hard_btn.pressed = false
			
			_easy_hearts.rect_position.y = HEARTS_Y_UNSELECTED
			_easy_text.rect_position.y = TEXT_Y_UNSELECTED
			
			_norm_hearts.rect_position.y = HEARTS_Y_SELECTED
			_norm_text.rect_position.y = TEXT_Y_SELECTED
			
			_hard_hearts.rect_position.y = HEARTS_Y_UNSELECTED
			_hard_text.rect_position.y = TEXT_Y_UNSELECTED
	elif difficulty == SaveLoadManager.DIFFICULTY.HARD:
			selected_difficulty = SaveLoadManager.DIFFICULTY.HARD
			_easy_btn.pressed = false
			_norm_btn.pressed = false
			_hard_btn.pressed = true
			
			_easy_hearts.rect_position.y = HEARTS_Y_UNSELECTED
			_easy_text.rect_position.y = TEXT_Y_UNSELECTED
			
			_norm_hearts.rect_position.y = HEARTS_Y_UNSELECTED
			_norm_text.rect_position.y = TEXT_Y_UNSELECTED
			
			_hard_hearts.rect_position.y = HEARTS_Y_SELECTED
			_hard_text.rect_position.y = TEXT_Y_SELECTED
	
	GlobalSounds.play("ButtonPressed")

# After confirming difficulty, attempt to create new game
func _on_difficulty_confirm():
	# Skip warning if no existing save to overwrite
	if not SaveLoadManager.check_save():
		_on_warning_confirm()
		return
	
	# If there is an existing save, show warning prompt
	# Also need to disable options from being able to be clicked on
	_warning_prompt.visible = true
	_easy_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_norm_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hard_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_difficulty_confirm_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_difficulty_cancel_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	GlobalSounds.play("ButtonPressed")

# Cancel new game, hide prompt and allow options to be clicked on again
func _on_difficulty_cancel():
	_continue_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_new_game_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_difficulty_prompt.visible = false
	
	GlobalSounds.play("ButtonPressed")

# Confirm new game
func _on_warning_confirm():
	_warning_confirm_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_warning_cancel_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	SaveLoadManager.reset_data()
	
	# Save selected difficulty
	var save_data = SaveLoadManager.load_data()
	save_data["difficulty"] = selected_difficulty
	SaveLoadManager.save_data(save_data)
	
	# Reset max hp
	PlayerHealth.set_max_hp()
	
	_fade.go_to_scene(LEVEL0)
	
	GlobalSounds.play("ButtonPressed")

# Cancel new game, hide prompt and allow options to be clicked on again
func _on_warning_cancel():
	_continue_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_new_game_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_warning_prompt.visible = false
	_difficulty_prompt.visible = false
	
	GlobalSounds.play("ButtonPressed")
