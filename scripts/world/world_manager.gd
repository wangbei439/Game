extends Node
class_name WorldManager

signal poi_discovered(poi_id: String)
signal teleport_unlocked(point_id: String)
signal boss_defeated(region_id: String)
signal material_added(material_id: String, amount: int)

@export var current_region_id: String = "dark_forest_outskirts"

var discovered_pois: Dictionary = {}
var unlocked_teleports: Dictionary = {}
var defeated_bosses: Dictionary = {}
var materials: Dictionary = {}

func _ready() -> void:
	add_to_group("world_manager")

func discover_poi(poi_id: String) -> bool:
	if poi_id.is_empty() or discovered_pois.has(poi_id):
		return false
	discovered_pois[poi_id] = true
	poi_discovered.emit(poi_id)
	return true

func unlock_teleport(point_id: String) -> bool:
	if point_id.is_empty() or unlocked_teleports.has(point_id):
		return false
	unlocked_teleports[point_id] = true
	teleport_unlocked.emit(point_id)
	return true

func mark_boss_defeated(region_id: String) -> bool:
	if region_id.is_empty() or defeated_bosses.has(region_id):
		return false
	defeated_bosses[region_id] = true
	boss_defeated.emit(region_id)
	return true

func add_material(material_id: String, amount: int = 1) -> int:
	if material_id.is_empty() or amount <= 0:
		return get_material_count(material_id)
	materials[material_id] = get_material_count(material_id) + amount
	material_added.emit(material_id, amount)
	return materials[material_id]

func get_material_count(material_id: String) -> int:
	return int(materials.get(material_id, 0))
