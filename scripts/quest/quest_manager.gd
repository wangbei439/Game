extends Node
class_name QuestManager

signal quest_started(quest_id: String)
signal quest_updated(quest_id: String, objective_id: String, current: int, required: int)
signal quest_completed(quest_id: String)

@export var quest_id: String = "whispers_at_forest_edge"

var objective_order: Array[String] = [
	"reach_abandoned_camp",
	"defeat_forest_creatures",
	"harvest_spores",
	"unlock_forest_teleport",
	"investigate_corrupted_shrine",
	"defeat_regional_boss",
	"return_to_outpost"
]
var objective_required: Dictionary = {
	"reach_abandoned_camp": 1,
	"defeat_forest_creatures": 3,
	"harvest_spores": 2,
	"unlock_forest_teleport": 1,
	"investigate_corrupted_shrine": 1,
	"defeat_regional_boss": 1,
	"return_to_outpost": 1
}
var objective_progress: Dictionary = {}
var active_index: int = 0
var is_completed: bool = false

func _ready() -> void:
	add_to_group("quest_manager")
	start_quest()

func start_quest() -> void:
	objective_progress.clear()
	for objective_id in objective_order:
		objective_progress[objective_id] = 0
	active_index = 0
	is_completed = false
	quest_started.emit(quest_id)

func register_event(event_id: String, amount: int = 1) -> void:
	if is_completed or not objective_progress.has(event_id):
		return
	var required: int = int(objective_required[event_id])
	var current: int = min(int(objective_progress[event_id]) + amount, required)
	objective_progress[event_id] = current
	quest_updated.emit(quest_id, event_id, current, required)
	_advance_completed_objectives()

func _advance_completed_objectives() -> void:
	while active_index < objective_order.size():
		var active_objective: String = objective_order[active_index]
		var required: int = int(objective_required[active_objective])
		if int(objective_progress[active_objective]) < required:
			return
		active_index += 1
	if not is_completed:
		is_completed = true
		quest_completed.emit(quest_id)

func get_active_objective() -> String:
	if is_completed or active_index >= objective_order.size():
		return ""
	return objective_order[active_index]

func get_active_progress() -> Dictionary:
	var objective_id: String = get_active_objective()
	if objective_id.is_empty():
		return {}
	return {
		"objective_id": objective_id,
		"current": int(objective_progress[objective_id]),
		"required": int(objective_required[objective_id])
	}
