extends SlotPage
## Pens: where Hearthlings live. The environment pushes an affinity each night; food is given here.
## Click an empty slot to hatch an egg there; click a Hearthling to open its workbench.


func _ready() -> void:
	%Workbench.closed.connect(func(): select(_sel))
	super()


func options() -> Array:
	return Database.get_all(&"pens").slice(0, 4).map(func(p: PenDef): return {"id": p.id, "name": p.name, "blurb": _pen_blurb(p)})


func slot(option: Dictionary, i: int) -> Dictionary:
	var here := _here(option.id)
	if i >= here.size():
		return {"title": "Empty", "blurb": "Click to hatch an egg here (%d in stock)." % GameState.eggs.size() if GameState.eggs else "Empty. Get eggs from requests or the Market."}
	var h: HearthlingData = here[i]
	var family: FamilyDef = Database.get_def(&"families", h.family_id)
	var status := "settled" if h.stabilized else "%d shaping day(s) left" % h.malleable_days_left
	if Shaping.can_shape(h) and not h.fed_today:
		status += ". Needs food today"
	return {"title": "%s #%d" % [family.name, h.uid], "blurb": status}


func slot_pressed(option: Dictionary, i: int) -> void:
	var here := _here(option.id)
	if i < here.size():
		%Workbench.open(here[i])
		return
	if GameState.eggs.is_empty():
		%Callout.say("No eggs. Take a request at the Front Desk or buy one at the Market.", get_viewport().get_mouse_position())
		return
	var egg: EggDef = GameState.eggs.pop_front()
	var h := Hatching.hatch(egg, Database.get_def(&"families", egg.family_id), GameState.new_uid())
	h.pen_id = option.id
	GameState.hearthlings[h.uid] = h
	EventBus.hearthling_hatched.emit(h)
	select(_sel)
	%Callout.say("It hatched!", get_viewport().get_mouse_position())


func _here(pen_id: StringName) -> Array:
	return GameState.hearthlings.values().filter(func(h): return h.pen_id == pen_id)


func _pen_blurb(p: PenDef) -> String:
	if p.affinity == Types.Affinity.NONE:
		return "A plain pen. No nightly push."
	return "%s each night." % Ink.chip("+%d %s" % [p.push_per_day, Types.Affinity.keys()[p.affinity].capitalize()], Types.AFFINITY_COLORS[p.affinity])
