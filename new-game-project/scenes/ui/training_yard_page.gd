extends SlotPage
## Training Yard: four yards, each with five slots. Settled Hearthlings placed here train overnight.


func options() -> Array:
	return Training.YARDS.map(func(y): return {"id": y.id, "name": y.name,
		"blurb": "Trains %s each night" % " and ".join(y.stats.map(func(s): return Ink.chip("+%d %s" % [Training.PER_NIGHT, Types.Stat.keys()[s].capitalize()], Types.STAT_COLORS[s])))})


func slot(option: Dictionary, i: int) -> Dictionary:
	var uid: int = _slots(option.id)[i]
	if not GameState.hearthlings.has(uid):
		return {"title": "Empty", "blurb": "Click to place a settled Hearthling here."}
	var h: HearthlingData = GameState.hearthlings[uid]
	var family: FamilyDef = Database.get_def(&"families", h.family_id)
	return {"title": "%s #%d" % [family.name, uid], "blurb": "Training here. Click to take it out.", "uid": uid}


func slot_pressed(option: Dictionary, i: int) -> void:
	var slots := _slots(option.id)
	if GameState.hearthlings.has(slots[i]):
		slots[i] = -1
		select(_sel)
		return
	var busy := []
	for s in GameState.yard_slots.values():
		busy.append_array(s)
	var free := GameState.hearthlings.values().filter(func(h): return h.stabilized and not busy.has(h.uid))
	if free.is_empty():
		%Callout.say("No settled Hearthlings free to train. Shaping ones settle when their days run out.", get_viewport().get_mouse_position())
		return
	var labels := PackedStringArray(free.map(func(h): return "%s #%d" % [Database.get_def(&"families", h.family_id).name, h.uid]))
	var pick: int = await %Chooser.ask(option.name, labels)
	if pick >= 0:
		slots[i] = free[pick].uid
		select(_sel)


func _slots(yard_id: StringName) -> Array:
	return GameState.yard_slots.get_or_add(yard_id, [-1, -1, -1, -1, -1])
