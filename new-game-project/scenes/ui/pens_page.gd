extends SlotPage
## Pens: four environments (the pen defs), each holding up to five eggs or Hearthlings.


func options() -> Array:
	return Database.get_all(&"pens").slice(0, 4).map(func(p: PenDef): return {"id": p.id, "name": p.name, "blurb": _pen_blurb(p)})


func slot(option: Dictionary, i: int) -> Dictionary:
	var here := GameState.hearthlings.values().filter(func(h): return h.pen_id == option.id)
	if i >= here.size():
		return {"title": "Empty", "blurb": "Room for an egg or a Hearthling."}
	var h: HearthlingData = here[i]
	var family: FamilyDef = Database.get_def(&"families", h.family_id)
	var status := "settled" if h.stabilized else "%d shaping day(s) left" % h.malleable_days_left
	return {"title": family.name, "blurb": "#%d, %s" % [h.uid, status]}


func _pen_blurb(p: PenDef) -> String:
	if p.affinity == Types.Affinity.NONE:
		return "A plain pen. No nightly push."
	var a := Ink.chip("+%d %s" % [p.push_per_day, Types.Affinity.keys()[p.affinity].capitalize()], Types.AFFINITY_COLORS[p.affinity])
	return "%s each night. Costs %d mana." % [a, p.mana_cost]
