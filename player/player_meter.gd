# Player meter singleton
extends Node

const MAX_METER = 100
var curr_meter = 0

# Add to meter, avoid going over
func add_meter(meter_gain):
	curr_meter = min(curr_meter + meter_gain, MAX_METER)

# Subtract from meter, avoid going below 0
func lose_meter(meter_loss):
	curr_meter = max(curr_meter - meter_loss, 0)
