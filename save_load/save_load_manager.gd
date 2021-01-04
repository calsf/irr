# Save load manager singleton
extends Node

const SAVE_PATH = "user://sav.json"

# Default data to be saved with new save file
var _default_data = {
	# Load level 0 by default, once finished, load level select
	"finished_level0" : false,
	
	# Player must complete tutorial
	"finished_tutorial" : false,
	
	# Level completion
	"level1_completed" : false,
	"level2_completed" : false,
	"level3_completed" : false,
	"level4_completed" : false,
	"level5_completed" : false,
	"level6_completed" : false,
	
	# Equipped weapons id, should both be empty by default
	"primary_weapon_id" : 0,
	"secondary_weapon_id" : 1,
	
	# Other settings
	"sound_muted" : false,
	"show_overhead" : true,
	
	"death_count" : 0
}

func save_data(data):
	# Create and open file
	var save_file = File.new()
	save_file.open_encrypted_with_pass(SAVE_PATH, File.WRITE, "")
	
	# Convert data to json, store, and close file
	save_file.store_line(to_json(data))
	save_file.close()

func load_data():
	# If no file to load from, first create save file with default values
	var save_file = File.new()
	if not save_file.file_exists(SAVE_PATH):
		save_data(_default_data)
		
	# Open file
	save_file.open_encrypted_with_pass(SAVE_PATH, File.READ, "")

	# Parse data then close file
	var data = parse_json(save_file.get_as_text())
	save_file.close()

	return data
