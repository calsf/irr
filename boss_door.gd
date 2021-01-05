extends Interactable
class_name BossDoor

export var boss_path = ""

onready var _anim = $AnimationPlayer
onready var _fade = get_tree().current_scene.get_node("CanvasLayer/Fade")

var player = null

func _ready():
	player = get_tree().current_scene.get_node("Player")
	player.connect("player_fell", self, "_go_to_boss")
	_anim.connect("animation_finished", self, "_player_fall")

# Stop player and open door
func interact():
	player.stop_player()
	_anim.play("open")

# Play player falling animation after door open animation
func _player_fall(_anim):
	player.player_fall()

func _go_to_boss():
	_fade.go_to_scene(boss_path)
