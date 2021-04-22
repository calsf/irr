extends Interactable

const DROP_OFFSET = 48 # offset from chest position that drops should appear at

onready var _anim = $AnimationPlayer
onready var _save_data = SaveLoadManager.load_data()

var _has_opened = false

# Weapon drops must correspond to their id order
var weapon_drops = [
	"res://weapons/longbow/LongbowPickup.tscn",
	"res://weapons/staff/StaffPickup.tscn",
	"res://weapons/sword/SwordPickup.tscn",
	"res://weapons/book/BookPickup.tscn",
	"res://weapons/shield/ShieldPickup.tscn",
	"res://weapons/arrow/ArrowPickup.tscn",
]

var meter_pickup = "res://walkover_pickups/meter_pickup/MeterFullPickup.tscn"

func interact():
	# Only allow open/interact once
	if _has_opened:
		return
	else:	# Set has opened to true and also disonnect label on area enter/exit
		_has_opened = true
		_interact_area.disconnect("area_entered", self, "_show_label")
		_interact_area.disconnect("area_exited", self, "_hide_label")
		_interact_label.visible = false
	
	randomize()
	var weap_id = randi() % weapon_drops.size()
	
	# First weapon drop starts at id of 5
	# Rerolls drop until it is a drop that player has not got yet
	# Player must also not have got all drops already
	_save_data = SaveLoadManager.load_data()	# Reload data first
	while _save_data["dropped_weapons"].size() < weapon_drops.size() and \
			(weap_id + 5) in _save_data["dropped_weapons"]:
		randomize()
		weap_id = randi() % weapon_drops.size()
	
	# If player has not got all drops yet, add new drop to dropped weapons and save
	if  _save_data["dropped_weapons"].size() < weapon_drops.size():
		_save_data["dropped_weapons"].append(weap_id + 5)
		SaveLoadManager.save_data(_save_data)
	
	# Load and spawn the weap drop
	var weap_loaded = load(weapon_drops[weap_id])
	var weap_drop = weap_loaded.instance()
	get_tree().get_root().add_child(weap_drop)
	
	# Also spawn a full meter pickup to allow weapon testing
	var meter_loaded = load(meter_pickup)
	var meter_drop = meter_loaded.instance()
	get_tree().get_root().add_child(meter_drop)
	
	# Randomly pick direction/position drops should go in
	var weapon_dir = null
	var meter_dir = null
	randomize()
	if randi() % 3 > 1:
		weapon_dir = Vector2.RIGHT
		meter_dir = Vector2.LEFT
	else:
		weapon_dir = Vector2.LEFT
		meter_dir = Vector2.RIGHT
	
	weap_drop.global_position = global_position
	weap_drop.target_pos = global_position + weapon_dir * DROP_OFFSET
	weap_drop.dir = weapon_dir
	weap_drop.drop()
	
	meter_drop.global_position = global_position
	meter_drop.target_pos = global_position + meter_dir * DROP_OFFSET
	meter_drop.dir = meter_dir
	meter_drop.drop()

	_anim.play("open")
