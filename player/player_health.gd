# Player health singleton
extends Node

const MAX_HP = 3
var curr_hp = MAX_HP

signal health_updated()

# Subtract from meter, avoid going below 0
func add_health(gain):
	curr_hp = min(curr_hp + gain, MAX_HP)
	emit_signal("health_updated")

# Add to health, avoid going over
func lose_health(loss):
	curr_hp = max(curr_hp - loss, 0)
	emit_signal("health_updated")
