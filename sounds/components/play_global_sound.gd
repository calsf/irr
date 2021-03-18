# Plays global sound, usually for objects that get created during runtime
# Will usually play the sound upon creation, may also play it during animation
# EX: EnemyDeath, sword empowered dmg objects, shield normal and empowered dmg objects
extends Node

export var sound_name = ""
export var play_onready = true	# Play on ready by default

# The room in which this object was created
var start_room_id = -1

# Play specified sound_name on ready if true
func _ready():
	# Objects created start in a room and will stay in their starting room
	start_room_id = PlayerRoom.curr_room_id
	
	if play_onready:
		play_sound()

# Play specified global sound_name
# ONLY PLAYS SOUND IF PLAYER IS CURRENTLY IN THE ROOM WHERE THIS OBJECT WAS CREATED
func play_sound():
	if start_room_id == PlayerRoom.curr_room_id:
		GlobalSounds.play(sound_name)


