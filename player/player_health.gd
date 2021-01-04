# Player health singleton
extends Node

const MAX_HP = 3
var curr_hp = MAX_HP

signal health_updated()
signal player_died()

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
			print(save_data["death_count"])

# Reset player health to max
func revive():
	curr_hp = MAX_HP
	emit_signal("health_updated")
