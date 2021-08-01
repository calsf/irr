extends Interactable
class_name FinalDoor

export var scene_path = ""

onready var _anim = $AnimationPlayer
onready var _fade = get_tree().current_scene.get_node("CanvasLayer/Fade")
onready var _save_data = SaveLoadManager.load_data()
onready var _dialog = $CanvasLayer/DialogContainer/DialogBoxFinalDoor

# Scene sounds
onready var _sounds = $Sounds

var player = null

func _ready():
	player = get_tree().current_scene.get_node("Player")
	player.connect("player_fell", self, "_go_to_scene")
	_anim.connect("animation_finished", self, "_player_fall")

# Stop player and open door
# ONLY OPEN DOOR IF PLAYER HAS COMPLETED ALL OTHER LEVELS, ELSE SHOW DIALOG
func interact():
	if _save_data["level1_completed"] and _save_data["level2_completed"] and \
			_save_data["level3_completed"] and _save_data["level4_completed"] and \
			_save_data["level5_completed"] and _save_data["level6_completed"]:
		player.stop_player()
		_anim.play("open")
		_sounds.play("DoorOpen")
	else:
		_dialog.activate_dialog()

# Play player falling animation after door open animation
func _player_fall(_animation):
	player.player_fall()

func _go_to_scene():
	_fade.go_to_scene(scene_path)
