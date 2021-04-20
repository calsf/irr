# For the starter weapon pickups that may appear on table and would have
# larger interact areas on table, but should have smaller areas outside table/tutorial
extends WeaponPickup
class_name TablePickup

onready var save_data = SaveLoadManager.load_data()

# Large interact area for table pickup
onready var _interact_area_default = $InteractArea/CollisionShape2D

# Smaller interact area for ground pickup
onready var _interact_area_alt = $InteractAreaAlt/CollisionShape2D

onready var _shadow = $Shadow

# Called when the node enters the scene tree for the first time.
func _ready():
	if save_data["finished_level0"]:	# Cannot be in tutorial lvl if finished it
		# Make sure to connect label to area enter/exit
		_interact_area_alt.get_parent().connect("area_entered", self, "_show_info")
		_interact_area_alt.get_parent().connect("area_exited", self, "_hide_info")
		
		# No longer on table, shadow z index should be -1
		_shadow.z_index = -1
	
		_interact_area_default.disabled = true
		_interact_area_alt.disabled = false
	else:	# In tutorial
		_interact_area_default.disabled = false
		_interact_area_alt.disabled = true


