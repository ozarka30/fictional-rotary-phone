extends SlotPage
## Training Yard: four environments. Each has activity slots (first) and creature slots (after).
## Each night a creature here gets the environment's effect plus its activity's. Food is fed here too.


func options() -> Array:
	return Database.get_all(&"envs").slice(0, 4).map(func(e: EnvDef): return {"id": e.id, "name": e.name, "env": e,
		"blurb": "Each night: %s" % Ink.effects(e)})


func slot(option: Dictionary, i: int) -> Dictionary:
	var env: EnvDef = option.env
	if i < env.activity_slots:
		var act_id: StringName = _activities(env)[i]
		if not act_id:
			return {"title": "+ Activity", "blurb": "Click to install an activity."}
		var act: ActivityDef = Database.get_def(&"activities", act_id)
		return {"title": act.name, "blurb": "%s\nClick to remove it." % Ink.effects(act)}
	var here := _here(env)
	var k := i - env.activity_slots
	if k >= here.size():
		return {"title": "Empty", "blurb": "Click to place a Hearthling here."}
	var h: HearthlingData = here[k]
	var doing: String = Database.get_def(&"activities", h.activity_id).name if h.activity_id else "Resting"
	return {"title": h.name, "blurb": doing, "uid": h.uid}


func slot_pressed(option: Dictionary, i: int) -> void:
	var env: EnvDef = option.env
	if i < env.activity_slots:
		await _activity_slot(env, i)
	else:
		var here := _here(env)
		var k := i - env.activity_slots
		if k < here.size():
			await _creature(env, here[k])
		else:
			await _place(env)
	select(_sel)


func _activity_slot(env: EnvDef, i: int) -> void:
	var acts := _activities(env)
	if acts[i]:
		for h in _here(env):
			if h.activity_id == acts[i]:
				h.activity_id = &""
		acts[i] = &""
		return
	var all := Database.get_all(&"activities").filter(func(a): return not acts.has(a.id))
	var pick: int = await %Chooser.ask("Install in %s" % env.name, PackedStringArray(all.map(func(a): return a.name)))
	if pick >= 0:
		acts[i] = all[pick].id


func _place(env: EnvDef) -> void:
	var free := GameState.hearthlings.values().filter(func(h): return not h.env_id)
	if free.is_empty():
		%Callout.say("No free Hearthlings. Bake one first.", get_viewport().get_mouse_position())
		return
	var pick: int = await %Chooser.ask(env.name, PackedStringArray(free.map(func(h): return h.name)))
	if pick < 0:
		return
	free[pick].env_id = env.id
	await _choose_activity(env, free[pick])


func _creature(env: EnvDef, h: HearthlingData) -> void:
	var pick: int = await %Chooser.ask(h.name, PackedStringArray(["Change activity", "Feed", "Take out", "Remold (keeps %d%% of its exp)" % (Baking.REMOLD_KEEP * 100)]))
	match pick:
		0: await _choose_activity(env, h)
		1: await _feed(h)
		2:
			h.env_id = &""
			h.activity_id = &""
		3:
			GameState.hearthlings.erase(h.uid)
			GameState.heartseeds.append(Baking.remold(h))
			%Callout.say("Its Heartseed is back on the bake shelf.", get_viewport().get_mouse_position())


func _choose_activity(env: EnvDef, h: HearthlingData) -> void:
	var acts := _activities(env).filter(func(a): return a)
	var labels := PackedStringArray(["Rest (environment only)"])
	labels.append_array(acts.map(func(a): return Database.get_def(&"activities", a).name))
	var pick: int = await %Chooser.ask("What should %s do?" % h.name, labels)
	if pick >= 0:
		h.activity_id = &"" if pick == 0 else acts[pick - 1]


func _feed(h: HearthlingData) -> void:
	if not Training.can_feed(h):
		%Callout.say("%s's toxicity is maxed out. It can't eat any more." % h.name, get_viewport().get_mouse_position())
		return
	var foods := Database.get_all(&"foods").filter(func(f): return GameState.materials.get(f.id, 0) > 0)
	if foods.is_empty():
		%Callout.say("No food. Buy some at the Market.", get_viewport().get_mouse_position())
		return
	var pick: int = await %Chooser.ask("Feed %s (toxicity %d/%d)" % [h.name, h.toxicity, Training.TOXICITY_MAX],
		PackedStringArray(foods.map(func(f): return "%s x%d  (+%d tox)" % [f.name, GameState.materials[f.id], f.toxicity])))
	if pick >= 0:
		Training.feed(h, foods[pick])
		GameState.add_material(foods[pick].id, -1)


func _activities(env: EnvDef) -> Array:
	var empty := []
	empty.resize(env.activity_slots)
	empty.fill(&"")
	return GameState.env_activities.get_or_add(env.id, empty)


func _here(env: EnvDef) -> Array:
	return GameState.hearthlings.values().filter(func(h): return h.env_id == env.id)
