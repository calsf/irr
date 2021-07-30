# Player health singleton
extends Node

var MAX_HP : int
var curr_hp : int

signal health_updated()
signal player_died()

func _ready():
	# Attempt to initialize MAX_HP off existing save file
	# Needs to be called again when difficulty gets updated (ex: creating new game)
	set_max_hp()

# Add to health, avoid going over
func add_health(gain):
	curr_hp = min(curr_hp + gain, MAX_HP)
	emit_signal("health_updated")

# Subtract from health, avoid going below 0
func lose_health(loss):
	if curr_hp > 0:
		curr_hp = max(curr_hp - loss, 0)
		emit_signal("health_updated")
		
		# If hp hits 0, player has died
		if curr_hp <= 0:
			emit_signal("player_died")
			var save_data = SaveLoadManager.load_data()
			save_data["death_count"] += 1
			SaveLoadManager.save_data(save_data)

# Set max hp
# Since player_health is autoloaded, need to call again when difficulty updated
func set_max_hp():
	if SaveLoadManager.check_save():
		var save_data = SaveLoadManager.load_data()
		if save_data["difficulty"] == SaveLoadManager.DIFFICULTY.EASY:
				MAX_HP = 5
		elif save_data["difficulty"] == SaveLoadManager.DIFFICULTY.NORMAL:
				MAX_HP = 3
		elif save_data["difficulty"] == SaveLoadManager.DIFFICULTY.HARD:
				MAX_HP = 1
	
	curr_hp = MAX_HP

# Reset player health to max
func revive():
	curr_hp = MAX_HP
	emit_signal("health_updated")
