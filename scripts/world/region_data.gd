extends Resource
class_name RegionData

@export var region_id: String = ""
@export var display_name: String = ""
@export var recommended_level: int = 1
@export var biome: String = ""
@export var accent_color: Color = Color.WHITE
@export var enemy_scenes: Array[PackedScene] = []
@export var harvest_items: Array[String] = []
@export var boss_scene: PackedScene
@export var teleport_point_ids: Array[String] = []
