extends Control
class_name QuestHUD

@export var quest_manager_path: NodePath = ^"../../QuestManager"

@onready var title_label: Label = $Panel/Margin/Rows/TitleLabel
@onready var objective_label: Label = $Panel/Margin/Rows/ObjectiveLabel
@onready var progress_label: Label = $Panel/Margin/Rows/ProgressLabel

const OBJECTIVE_TEXT: Dictionary = {
	"reach_abandoned_camp": "Reach the abandoned camp",
	"defeat_forest_creatures": "Defeat forest creatures",
	"harvest_spores": "Harvest spore clusters",
	"unlock_forest_teleport": "Unlock the forest teleport point",
	"investigate_corrupted_shrine": "Investigate the corrupted shrine",
	"defeat_regional_boss": "Defeat the regional boss",
	"return_to_outpost": "Return to the outpost"
}

var quest_manager: QuestManager
var last_objective_id: String = ""
var last_current: int = -1
var last_required: int = -1

func _ready() -> void:
	_resolve_quest_manager()
	_apply_theme()
	_refresh_display(true)

func _process(_delta: float) -> void:
	_refresh_display(false)

func _resolve_quest_manager() -> void:
	var manager_node: Node = get_node_or_null(quest_manager_path)
	if manager_node == null:
		manager_node = get_tree().get_first_node_in_group("quest_manager")
	if manager_node is QuestManager:
		quest_manager = manager_node
		if not quest_manager.quest_started.is_connected(_on_quest_started):
			quest_manager.quest_started.connect(_on_quest_started)
		if not quest_manager.quest_updated.is_connected(_on_quest_updated):
			quest_manager.quest_updated.connect(_on_quest_updated)
		if not quest_manager.quest_completed.is_connected(_on_quest_completed):
			quest_manager.quest_completed.connect(_on_quest_completed)

func _refresh_display(force: bool) -> void:
	if quest_manager == null:
		_resolve_quest_manager()
		if quest_manager == null:
			_set_missing_manager_text()
			return
	var progress: Dictionary = quest_manager.get_active_progress()
	if progress.is_empty():
		if force or last_objective_id != "complete":
			title_label.text = "Forest Edge"
			objective_label.text = "Quest complete"
			progress_label.text = "Return to the outpost for the next lead."
			last_objective_id = "complete"
		return
	var objective_id: String = String(progress.get("objective_id", ""))
	var current: int = int(progress.get("current", 0))
	var required: int = int(progress.get("required", 1))
	if not force and objective_id == last_objective_id and current == last_current and required == last_required:
		return
	title_label.text = "Forest Edge"
	objective_label.text = OBJECTIVE_TEXT.get(objective_id, objective_id.capitalize())
	progress_label.text = "%d / %d" % [current, required]
	last_objective_id = objective_id
	last_current = current
	last_required = required

func _set_missing_manager_text() -> void:
	title_label.text = "Forest Edge"
	objective_label.text = "Quest manager not found"
	progress_label.text = ""

func _apply_theme() -> void:
	var panel: PanelContainer = $Panel
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.05, 0.08, 0.82)
	style.border_color = Color(0.18, 0.85, 0.95, 0.88)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	panel.add_theme_stylebox_override("panel", style)
	title_label.add_theme_color_override("font_color", Color(0.56, 0.95, 1.0))
	objective_label.add_theme_color_override("font_color", Color(0.94, 0.96, 0.98))
	progress_label.add_theme_color_override("font_color", Color(0.68, 0.78, 0.88))
	title_label.add_theme_font_size_override("font_size", 16)
	objective_label.add_theme_font_size_override("font_size", 18)
	progress_label.add_theme_font_size_override("font_size", 14)
	for label in [title_label, objective_label, progress_label]:
		label.custom_minimum_size = Vector2(0.0, 24.0)

func _on_quest_started(_quest_id: String) -> void:
	_refresh_display(true)

func _on_quest_updated(_quest_id: String, _objective_id: String, _current: int, _required: int) -> void:
	_refresh_display(true)

func _on_quest_completed(_quest_id: String) -> void:
	_refresh_display(true)
