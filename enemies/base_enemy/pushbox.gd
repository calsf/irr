# Mostly needed for enemies that will move to player as they may stack on top of eachother
# Checks for stacking and push away from eachother
extends Area2D

# Responsible for flock-like behavior based on overlapping pushbox
# Check if any flock area is overlapping, want to push away from eachother
func check_push():
	var areas = get_overlapping_areas()
	if areas:
		return (global_position - areas[0].global_position).normalized()
	else:
		return Vector2.ZERO
