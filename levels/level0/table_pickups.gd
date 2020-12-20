# If player is already holding one of the starter weapons, do not show them on table
extends StaticBody2D

onready var dagger_pickup = $DaggerPickup
onready var shortbow_pickup = $ShortbowPickup
onready var wand_pickup = $WandPickup
onready var save_data = SaveLoadManager.load_data()

# Called when the node enters the scene tree for the first time.
func _ready():
	# Weapon pickups yield for frame pre draw so yield before freeing
	yield(VisualServer, "frame_pre_draw")
	
	if save_data["primary_weapon_id"] == dagger_pickup.weapon_id \
			or save_data["secondary_weapon_id"] == dagger_pickup.weapon_id:
		dagger_pickup.queue_free()
	
	if save_data["primary_weapon_id"] == shortbow_pickup.weapon_id \
			or save_data["secondary_weapon_id"] == shortbow_pickup.weapon_id:
		shortbow_pickup.queue_free()
		
	if save_data["primary_weapon_id"] == wand_pickup.weapon_id \
			or save_data["secondary_weapon_id"] == wand_pickup.weapon_id:
		wand_pickup.queue_free()

