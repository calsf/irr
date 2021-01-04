# Player meter singleton
extends Node

const MAX_METER = 100
var curr_meter = 0

signal meter_updated()

# Add to meter, avoid going over
func add_meter(meter_gain):
	curr_meter = min(curr_meter + meter_gain, MAX_METER)
	emit_signal("meter_updated")

# Subtract from meter, avoid going below 0
func lose_meter(meter_loss):
	curr_meter = max(curr_meter - meter_loss, 0)
	emit_signal("meter_updated")

# Reset meter to 0
func reset():
	curr_meter = 0
	emit_signal("meter_updated")
