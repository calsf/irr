extends Node

func play(sound):
	if (!SaveLoadManager.load_data()["sound_muted"]):
		get_node(sound).play()
