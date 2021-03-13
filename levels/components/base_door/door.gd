extends Interactable
class_name Door

export var scene_path = ""

onready var _anim = $AnimationPlayer
onready var _fade = get_tree().current_scene.get_node("CanvasLayer/Fade")

# Scene sounds
onready var _sounds = $Sounds

var player = null

func _ready():
	player = get_tree().current_scene.get_node("Player")
	player.connect("player_fell", self, "_go_to_scene")
	_anim.connect("animation_finished", self, "_player_fall")

# Stop player and open door
func interact():
	player.stop_player()
	_anim.play("open")
	
	_sounds.play("DoorOpen")

# Play player falling animation after door open animation
func _player_fall(_animation):
	player.player_fall()

func _go_to_scene():
	_fade.go_to_scene(scene_path)
