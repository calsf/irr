extends Node2D
class_name WeaponPickup

const OFFSET = 40
const BG_PADDING = 8

export var _weapon_props : Resource
export var _normal_damage_props : Resource
export var _emp_damage_props : Resource

# weapon_id is used to refer to weapon in Player's Weapons children
onready var weapon_id = _weapon_props.weapon_id
onready var _interact_area = $InteractArea
onready var _info_display = $InfoDisplay
onready var _display_bg = $DisplayBG
onready var _name_bg = $NameBG
onready var _outline_bg = $OutlineBG

func _ready():
	# Get info from weapon props and display
	_name_bg.get_node("WeaponName").text = _weapon_props.weapon_name
	_info_display.get_node("WeaponNormal").text = _weapon_props.normal_desc
	_info_display.get_node("WeaponEmpowered").text = _weapon_props.empow_desc
	_info_display.get_node("NormalAttack").text += " / DMG " + str(_normal_damage_props.base_damage) +  \
			" / METER +" + str(_normal_damage_props.meter_gain)
	_info_display.get_node("EmpoweredAttack").text += " / DMG " + str(_emp_damage_props.base_damage) +  \
			" / METER -" + str(_weapon_props.empow_cost)
	
	_interact_area.connect("area_entered", self, "_show_info")
	_interact_area.connect("area_exited", self, "_hide_info")
	
	# Wait one render frame for text boxes to resize
	yield(VisualServer, "frame_pre_draw")
	_display_bg.rect_size.y = _info_display.rect_size.y + BG_PADDING
	_outline_bg.rect_size.y = _display_bg.rect_size.y + _name_bg.rect_size.y + 2
	
	# Offset display above pickup based on the info size
	var y_offset = OFFSET + (_info_display.rect_size.y + _info_display.rect_position.y)
	_info_display.rect_position.y -= y_offset
	_display_bg.rect_position.y -= y_offset
	_name_bg.rect_position.y -= y_offset
	_outline_bg.rect_position.y -= y_offset
	
func _show_info(area):
	_info_display.visible = true
	_display_bg.visible = true
	_name_bg.visible = true
	_outline_bg.visible = true

func _hide_info(area):
	_info_display.visible = false
	_display_bg.visible = false
	_name_bg.visible = false
	_outline_bg.visible = false
