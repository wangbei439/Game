class_name PlayerStats

var base_attack = 10
var base_defense = 0
var base_max_hp = 100
var max_hp = 100
var hp = 100
var equipped = {}
var inventory = []
var inventory_size = 20

func equip_item(item):
	if item == null:
		return
	equipped[item.slot] = item
	recalculate()

func unequip_slot(slot):
	if equipped.has(slot):
		equipped.erase(slot)
		recalculate()

func recalculate():
	max_hp = base_max_hp
	for item in equipped.values():
		max_hp += item.hp_bonus
	hp = min(hp, max_hp)

func add_item(item):
	if inventory.size() >= inventory_size:
		return false
	inventory.append(item)
	return true

func remove_item(index):
	if index >= 0 and index < inventory.size():
		inventory.remove_at(index)

func get_attack():
	var total = base_attack
	for item in equipped.values():
		total += item.attack
	return total

func get_defense():
	var total = base_defense
	for item in equipped.values():
		total += item.defense
	return total

func take_damage(amount, is_dodging):
	if is_dodging:
		return 0
	var final_damage = max(1, amount - get_defense())
	hp -= final_damage
	hp = max(hp, 0)
	return final_damage

func is_dead():
	return hp <= 0

func respawn():
	hp = max_hp
