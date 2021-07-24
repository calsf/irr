extends Node

onready var weapon_pickups = get_children()

# Starter weapon ids
var starter_ids = [2, 3, 4]

# Only keep starter weapon pickups and weapons that have been dropped from chests
# They must also not be the player's primary or secondary weapon
func _ready():
	var save_data = SaveLoadManager.load_data()
	
	for pickup in weapon_pickups:
		if pickup.weapon_id in starter_ids:
			if pickup.weapon_id == save_data["primary_weapon_id"] or \
					pickup.weapon_id == save_data["secondary_weapon_id"]:
				pickup.visible = false
				pickup.get_node("InteractArea/CollisionShape2D").disabled = true
			else:
				pickup.visible = true
		elif not pickup.weapon_id in save_data["dropped_weapons"] or \
				pickup.weapon_id == save_data["primary_weapon_id"] or \
				pickup.weapon_id == save_data["secondary_weapon_id"]:
			pickup.visible = false
			pickup.get_node("InteractArea/CollisionShape2D").disabled = true
		else:
			pickup.visible = true
		

