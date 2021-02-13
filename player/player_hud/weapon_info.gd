# For the weapon info display in PlayerHUD
extends Control

const OFFSET = 40
const BG_PADDING = 8

onready var _info_display = $InfoDisplay
onready var _display_bg = $DisplayBG
onready var _name_bg = $NameBG
onready var _outline_bg = $OutlineBG
onready var player = get_tree().current_scene.get_node("Player")

# Update info to show PRIMARY WEAPON information
func update_info_primary():
	if "Empty" in player.weapon_primary.weapon_props.weapon_name:
		return
	
	_name_bg.get_node("WeaponName").text = player.weapon_primary.weapon_props.weapon_name
	_info_display.get_node("WeaponNormal").text = player.weapon_primary.weapon_props.normal_desc
	_info_display.get_node("WeaponEmpowered").text = player.weapon_primary.weapon_props.empow_desc
	_info_display.get_node("NormalAttack").text = "Normal / DMG " + str(player.weapon_primary.normal_damage_props.base_damage) +  \
			" / METER +" + str(player.weapon_primary.normal_damage_props.meter_gain)
	_info_display.get_node("EmpoweredAttack").text = "Empowered / DMG " + str(player.weapon_primary.emp_damage_props.base_damage) +  \
			" / METER -" + str(player.weapon_primary.weapon_props.empow_cost)
	resize()

# Update info to show SECONDARY WEAPON information
func update_info_secondary():
	if "Empty" in player.weapon_secondary.weapon_props.weapon_name:
		return
	
	_name_bg.get_node("WeaponName").text = player.weapon_secondary.weapon_props.weapon_name
	_info_display.get_node("WeaponNormal").text = player.weapon_secondary.weapon_props.normal_desc
	_info_display.get_node("WeaponEmpowered").text = player.weapon_secondary.weapon_props.empow_desc
	_info_display.get_node("NormalAttack").text = "Normal / DMG " + str(player.weapon_secondary.normal_damage_props.base_damage) +  \
			" / METER +" + str(player.weapon_secondary.normal_damage_props.meter_gain)
	_info_display.get_node("EmpoweredAttack").text = "Empowered / DMG " + str(player.weapon_secondary.emp_damage_props.base_damage) +  \
			" / METER -" + str(player.weapon_secondary.weapon_props.empow_cost)
	resize()

# Resize text boxes
func resize():
	# Wait one render frame for text boxes to resize
	yield(VisualServer, "frame_pre_draw")
	_display_bg.rect_size.y = _info_display.rect_size.y + BG_PADDING
	_outline_bg.rect_size.y = _display_bg.rect_size.y + _name_bg.rect_size.y + 2
