extends Node

var enemy_hurt_sounds = []
var curr = 0

var enemy_spawn_sounds = []
var curr_enemy_spawn = 0

func _ready():
	enemy_hurt_sounds = [
		get_node("EnemyHurt1"), 
		get_node("EnemyHurt2"), 
		get_node("EnemyHurt3")
		]
		
	enemy_spawn_sounds = [
		get_node("EnemySpawn1"), 
		get_node("EnemySpawn2"), 
		get_node("EnemySpawn3")
		]

func play(sound):
	if (!SaveLoadManager.load_data()["sound_muted"]):
		get_node(sound).play()

# Loop/cycle through enemy hurt sounds sequentially
func play_enemy_hurt():
	if (!SaveLoadManager.load_data()["sound_muted"]):
		enemy_hurt_sounds[curr].play()
		curr += 1
		
		if curr > enemy_hurt_sounds.size() - 1:
			curr = 0

# Loop/cycle through enemy spawn sounds sequentially
func play_enemy_spawn():
	if (!SaveLoadManager.load_data()["sound_muted"]):
		enemy_spawn_sounds[curr_enemy_spawn].play()
		curr_enemy_spawn += 1
		
		if curr_enemy_spawn > enemy_spawn_sounds.size() - 1:
			curr_enemy_spawn = 0
