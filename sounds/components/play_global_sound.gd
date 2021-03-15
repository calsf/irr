extends Node

export var sound_name = ""
export var play_onready = true	# Play on ready by default

# Play specified sound_name on ready if true
func _ready():
	if play_onready:
		play_sound()

# Play specified global sound_name
func play_sound():
	GlobalSounds.play(sound_name)


