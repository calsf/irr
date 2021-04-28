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
var health_pickup = "res://walkover_pickups/health_pickup/HealthFullPickup.tscn"

func interact():
	pass
