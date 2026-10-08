extends Control
## Market: rows of shop boxes, one per thing for sale (every food and egg def for now).

const ITEM := preload("res://scenes/ui/shop_item.tscn")
const STOCK := [&"eggs", &"foods"]  # ponytail: everything is always in stock; vendors and levels later


func _ready() -> void:
	for category in STOCK:
		for def in Database.get_all(category):
			var box: ShopItem = ITEM.instantiate()
			box.item = def
			box.blurb = _blurb(def)
			box.pressed.connect(func(_p): _buy(box))
			box.mouse_entered.connect(func(): %Callout.say(box.blurb, box.global_position + Vector2(box.size.x * 0.5, 8)))
			box.mouse_exited.connect(%Callout.hide)
			%Grid.add_child(box)
	EventBus.coin_changed.connect(func(_c): _refresh())
	_refresh()


func _buy(box: ShopItem) -> void:
	var def: Resource = box.item
	if GameState.coin < def.cost:
		%Callout.say("Not enough coin.", box.global_position + Vector2(box.size.x * 0.5, 8))
		return
	GameState.add_coin(-def.cost)
	if def is EggDef:
		GameState.eggs.append(def)
	else:
		GameState.add_material(def.id, 1)  # ponytail: food sits in materials until feeding costs stock
	%Callout.say("Bought %s!" % def.name, box.global_position + Vector2(box.size.x * 0.5, 8))


func _refresh() -> void:
	%Subtitle.text = "%d coin" % GameState.coin


func _blurb(def: Resource) -> String:
	if def is EggDef:
		return "Grade %s egg. %s" % [Ink.grade(def.grade, "", 20), Ink.chip("%d shaping days" % def.malleable_days, Types.DAYS_COLOR)]
	var bits := PackedStringArray()
	for a in def.affinity_deltas:
		bits.append(Ink.chip("+%d %s" % [def.affinity_deltas[a], Types.Affinity.keys()[a].capitalize()], Types.AFFINITY_COLORS[a]))
	for s in def.potential_deltas:
		bits.append(Ink.chip("+%d %s cap" % [def.potential_deltas[s], Types.Stat.keys()[s].capitalize()], Types.STAT_COLORS[s]))
	for s in def.stat_deltas:
		bits.append(Ink.chip("+%d %s" % [def.stat_deltas[s], Types.Stat.keys()[s].capitalize()], Types.STAT_COLORS[s]))
	return ", ".join(bits)
