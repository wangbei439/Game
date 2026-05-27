extends Area3D

var item_data = null
var bob_time = 0.0

func _ready():
	body_entered.connect(_on_body_entered)

func _process(delta):
	bob_time += delta
	$body.position.y = 0.2 + sin(bob_time * 3.0) * 0.15
	$OmniLight3D.light_energy = 1.5 + sin(bob_time * 5.0) * 0.5

func setup(item):
	item_data = item
	$body.mesh.surface_get_material(0).albedo_color = get_quality_color(item.quality)

func get_quality_color(quality):
	match quality:
		0: return Color.WHITE
		1: return Color.GREEN
		2: return Color.BLUE
		3: return Color.PURPLE
		4: return Color.ORANGE
		_: return Color.WHITE

func _on_body_entered(body):
	if body.name == "Player" and item_data != null:
		if body.stats.add_item(item_data):
			print("拾取了: ", item_data.name)
			queue_free()
		else:
			print("背包已满！")
