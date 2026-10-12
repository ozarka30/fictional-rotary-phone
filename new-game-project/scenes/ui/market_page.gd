extends Control
## Market: rows of shop boxes, one per thing for sale (molds, dough, mix-ins, food, training machines, Heartseeds).

const ITEM := preload("res://scenes/ui/shop_item.tscn")
const STOCK := [&"molds", &"doughs", &"mixins", &"foods", &"activities", &"seeds"]  # ponytail: everything is always in stock; vendors and levels later


const TABS := {&"molds": "Molds", &"doughs": "Dough", &"mixins": "Mix-ins", &"foods": "Food", &"activities": "Machines", &"seeds": "Heartseeds"}


func _ready() -> void:
	for category in STOCK:
		var tab := Button.new()
		tab.text = TABS[category]
		tab.focus_mode = Control.FOCUS_NONE
		tab.pressed.connect(_show.bind(category))
		%Tabs.add_child(tab)
	EventBus.coin_changed.connect(func(_c): _refresh())
	_refresh()
	_show(STOCK[0])


## One category at a time, so the page fits the screen.
func _show(category: StringName) -> void:
	for i in STOCK.size():
		%Tabs.get_child(i).modulate = Color.WHITE if STOCK[i] == category else Color(0.62, 0.62, 0.62)
	for c in %Grid.get_children():
		c.queue_free()
	for def in Database.get_all(category):
		if (def is MoldDef and def.cost == 0) or (def is ActivityDef and not def.machine):
			continue  # starter molds and basic activities aren't sold
		var box: ShopItem = ITEM.instantiate()
		box.item = def
		box.blurb = Ink.effects(def)
		box.pressed.connect(func(_p): _buy(box))
		box.mouse_entered.connect(func(): %Callout.say(box.blurb, box.global_position + Vector2(box.size.x * 0.5, 8)))
		box.mouse_exited.connect(%Callout.hide)
		%Grid.add_child(box)


func _buy(box: ShopItem) -> void:
	var def: Resource = box.item
	var at := box.global_position + Vector2(box.size.x * 0.5, 8)
	if def is MoldDef and GameState.molds.get(def.id, 0) == -1:
		%Callout.say("You already own this mold.", at)
		return
	if GameState.coin < def.cost:
		%Callout.say("Not enough coin.", at)
		return
	GameState.add_coin(-def.cost)
	if def is MoldDef:
		GameState.molds[def.id] = def.uses if def.uses < 0 else GameState.molds.get(def.id, 0) + def.uses
	elif def is Heartseed:
		var seed: Heartseed = def.duplicate(true)
		seed.uid = GameState.new_uid()
		GameState.heartseeds.append(seed)
	else:
		GameState.add_material(def.id, 1)
	%Callout.say("Bought %s!" % def.name, at)


func _refresh() -> void:
	%Subtitle.text = "%d coin" % GameState.coin
