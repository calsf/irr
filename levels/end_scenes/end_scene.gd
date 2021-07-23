extends Node2D

const EASY = "EASY MODE"
const NORM = "NORMAL MODE"
const HARD = "HARD MODE"

const NEXT_SCENE = "res://levels/title_scene/TitleScene.tscn"

onready var _fade = $CanvasLayer/Fade
onready var _deaths = $CanvasLayer/Stats/Deaths
onready var _difficulty = $CanvasLayer/Stats/Difficulty
onready var _continue_btn = $CanvasLayer/ContinueContainer/Continue

# Set deaths and difficulty text based on saved values
func _ready():
	var save_data = SaveLoadManager.load_data()
	
	if save_data["death_count"] == 1:
		_deaths.text = str(save_data["death_count"]) + " DEATH"
	else:
		_deaths.text = str(save_data["death_count"]) + " DEATHS"
	
	if save_data["difficulty"] == SaveLoadManager.DIFFICULTY.EASY:
		_difficulty.text = EASY
	elif save_data["difficulty"] == SaveLoadManager.DIFFICULTY.NORMAL:
		_difficulty.text = NORM
	elif save_data["difficulty"] == SaveLoadManager.DIFFICULTY.HARD:
		_difficulty.text = HARD
	
	_continue_btn.connect("mouse_entered", self, "_on_continue_enter")
	_continue_btn.connect("mouse_exited", self, "_on_continue_exit")
	_continue_btn.connect("pressed", self, "_on_continue_pressed")

# On hover for continue button
func _on_continue_enter():
	_continue_btn.rect_scale = Vector2(1.2, 1.2)

# On exit for continue button
func _on_continue_exit():
	_continue_btn.rect_scale = Vector2(1, 1)

# Go to scene when press continue button
func _on_continue_pressed():
	_continue_btn.disabled = true
	_fade.go_to_scene(NEXT_SCENE)
