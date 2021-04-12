extends Node

# Counter for curr loop of sounds, only used for play_one_of
var curr = 0

func play(sound):
	if (!SaveLoadManager.load_data()["sound_muted"]):
		get_node(sound).play()

# Play one of 3 sounds of the sound name, should loop through them
# NOTE: 1 script can only handle one set of 3 sounds to loop through since only 1 curr 
func play_one_of(sound):
	if (!SaveLoadManager.load_data()["sound_muted"]):
		var sounds = [
			get_node(sound + "1"),
			get_node(sound + "2"),
			get_node(sound + "3")
		]
		sounds[curr].play()
		curr += 1
		
		if curr > sounds.size() - 1:
			curr = 0
