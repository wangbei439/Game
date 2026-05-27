extends Control

var player_node = null
var is_open = false

func _ready():
	visible = false

func _process(delta):
	if Input.is_key_pressed(KEY_I):
		if not is_open:
			open()
		else:
			close()

func open():
	if player_node == null:
		player_node = get_node_or_null("../../Player")
	visible = true
	is_open = true
	refresh()

func close():
	visible = false
	is_open = false

func refresh():
	# 清空旧的槽位
	for child in $bg_panel/slots_container.get_children():
		child.queue_free()
	
	# 装备槽标题
	var equip_label = Label.new()
	equip_label.text = "—— 装备栏 ——"
	$bg_panel/slots_container.add_child(equip_label)
	
	# 显示已装备的物品
	if player_node:
		for slot_key in player_node.stats.equipped:
			var item = player_node.stats.equipped[slot_key]
			var btn = Button.new()
			btn.text = "[装备] " + item.name + " (攻+" + str(item.attack) + " 防+" + str(item.defense) + ")"
			$bg_panel/slots_container.add_child(btn)
	
	# 背包标题
	var inv_label = Label.new()
	inv_label.text = "—— 背包 ——"
	$bg_panel/slots_container.add_child(inv_label)
	
	# 显示背包物品
	if player_node:
		for i in range(player_node.stats.inventory.size()):
			var item = player_node.stats.inventory[i]
			var btn = Button.new()
			btn.text = item.name + " (攻+" + str(item.attack) + " 防+" + str(item.defense) + ")"
			var slot_name = EquipmentData.Slot.keys()[item.slot]
			btn.tooltip_text = "点击装备到 " + slot_name + " 槽"
			$bg_panel/slots_container.add_child(btn)
			btn.pressed.connect(_on_item_clicked.bind(i))
	
	# 属性显示
	if player_node:
		var stat_label = Label.new()
		stat_label.text = "攻击: " + str(player_node.stats.get_attack()) + "  防御: " + str(player_node.stats.get_defense()) + "  HP: " + str(player_node.stats.hp) + "/" + str(player_node.stats.max_hp)
		$bg_panel/slots_container.add_child(stat_label)

func _on_item_clicked(index):
	if player_node:
		var item = player_node.stats.inventory[index]
		player_node.stats.equip_item(item)
		player_node.stats.inventory.remove_at(index)
		refresh()
