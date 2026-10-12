extends SlotPage
## Training Yard: four environments, each with slots that hold one Hearthling.
## A slot can also have a training machine installed; the machine becomes an extra activity for that slot.
## Each night a Hearthling gets the environment's effect plus its activity's. Food is fed here too.


func options() -> Array:
	return Database.get_all(&"envs").slice(0, 4).map(func(e: EnvDef): return {"id": e.id, "name": e.name, "env": e,
		"blurb": "Each night: %s" % Ink.effects(e)})


func slot(option: Dictionary, i: int) -> Dictionary:
	var s: Dictionary = GameState.slots(option.env)[i]
	var machine := ("\nMachine: %s" % _act(s.machine).name) if s.machine else ""
	if not GameState.hearthlings.has(s.uid):
		return {"title": "Empty", "blurb": "Click to place a Hearthling or install a machine.%s" % machine}
	var doing: String = _act(s.activity).name if s.activity else "Resting"
	return {"title": GameState.hearthlings[s.uid].name, "blurb": doing + machine, "uid": s.uid}


func slot_pressed(option: Dictionary, i: int) -> void:
	var s: Dictionary = GameState.slots(option.env)[i]
	if GameState.hearthlings.has(s.uid):
		await _creature(s, GameState.hearthlings[s.uid])
	else:
		var labels := PackedStringArray(["Place a Hearthling", "Remove machine" if s.machine else "Install a machine"])
		var pick: int = await %Chooser.ask(option.name, labels)
		match pick:
			0: await _place(s)
			1: await _machine(s)
	select(_sel)


func _place(s: Dictionary) -> void:
	var free := GameState.hearthlings.values().filter(func(h): return GameState.slot_of(h.uid).is_empty())
	if free.is_empty():
		%Callout.say("No free Hearthlings. Bake one first.", get_viewport().get_mouse_position())
		return
	var pick: int = await %Chooser.ask("Who trains here?", PackedStringArray(free.map(func(h): return h.name)))
	if pick >= 0:
		s.uid = free[pick].uid
		await _choose_activity(s, free[pick])


## Install a machine you own into this slot, or take the installed one back out.
func _machine(s: Dictionary) -> void:
	if s.machine:
		GameState.add_material(s.machine, 1)
		if s.activity == s.machine:
			s.activity = &""
		s.machine = &""
		return
	var owned := Database.get_all(&"activities").filter(func(a): return a.machine and GameState.materials.get(a.id, 0) > 0)
	if owned.is_empty():
		%Callout.say("No training machines. Buy them at the Market.", get_viewport().get_mouse_position())
		return
	var pick: int = await %Chooser.ask("Install a machine", PackedStringArray(owned.map(func(a): return "%s  -  %s" % [a.name, Ink.plain(Ink.effects(a))])))
	if pick >= 0:
		s.machine = owned[pick].id
		GameState.add_material(s.machine, -1)


func _creature(s: Dictionary, h: HearthlingData) -> void:
	var labels := PackedStringArray(["Change activity", "Feed", "Take out", "Remold (keeps %d%% of its exp)" % (Baking.REMOLD_KEEP * 100),
		"Remove machine" if s.machine else "Install a machine"])
	var pick: int = await %Chooser.ask(h.name, labels)
	match pick:
		0: await _choose_activity(s, h)
		1: await _feed(h)
		2:
			s.uid = -1
			s.activity = &""
		3:
			GameState.remove_hearthling(h.uid)
			s.activity = &""
			GameState.heartseeds.append(Baking.remold(h))
			%Callout.say("Its Heartseed is back on the bake shelf.", get_viewport().get_mouse_position())
		4: await _machine(s)


## Basic activities, plus this slot's machine if one is installed.
func _choose_activity(s: Dictionary, h: HearthlingData) -> void:
	var acts := Database.get_all(&"activities").filter(func(a): return not a.machine or a.id == s.machine)
	var labels := PackedStringArray(["Rest (environment only)"])
	labels.append_array(acts.map(func(a): return ("[Machine] " if a.machine else "") + "%s  -  %s" % [a.name, Ink.plain(Ink.effects(a))]))
	var pick: int = await %Chooser.ask("What should %s do?" % h.name, labels)
	if pick >= 0:
		s.activity = &"" if pick == 0 else acts[pick - 1].id


func _feed(h: HearthlingData) -> void:
	if not Training.can_feed(h):
		%Callout.say("%s's toxicity is maxed out. It can't eat any more." % h.name, get_viewport().get_mouse_position())
		return
	var foods := Database.get_all(&"foods").filter(func(f): return GameState.materials.get(f.id, 0) > 0)
	if foods.is_empty():
		%Callout.say("No food. Buy some at the Market.", get_viewport().get_mouse_position())
		return
	var pick: int = await %Chooser.ask("Feed %s (toxicity %d/%d)" % [h.name, h.toxicity, Training.TOXICITY_MAX],
		PackedStringArray(foods.map(func(f): return "%s x%d  -  %s" % [f.name, GameState.materials[f.id], Ink.plain(Ink.effects(f))])))
	if pick >= 0:
		Training.feed(h, foods[pick])
		GameState.add_material(foods[pick].id, -1)


func _act(id: StringName) -> ActivityDef:
	return Database.get_def(&"activities", id)
