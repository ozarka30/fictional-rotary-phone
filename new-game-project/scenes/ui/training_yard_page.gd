extends SlotPage
## Training Yard: four yards, each with five training slots.

# ponytail: yards as consts until they need costs, unlocks or art (then a YardDef in data/yards)
const YARDS := [
	{"id": &"obstacle_run", "name": "Obstacle Run", "stats": [Types.Stat.PACE, Types.Stat.BRAWN]},
	{"id": &"scent_trail", "name": "Scent Trail", "stats": [Types.Stat.KNACK, Types.Stat.WITS]},
	{"id": &"sparring_ring", "name": "Sparring Ring", "stats": [Types.Stat.GRIT, Types.Stat.BRAWN]},
	{"id": &"calm_garden", "name": "Calm Garden", "stats": [Types.Stat.HEART, Types.Stat.WITS]},
]


func options() -> Array:
	return YARDS.map(func(y): return {"id": y.id, "name": y.name,
		"blurb": "Trains " + " and ".join(y.stats.map(func(s): return Ink.chip(Types.Stat.keys()[s].capitalize(), Types.STAT_COLORS[s])))})


func slot(option: Dictionary, i: int) -> Dictionary:
	var uid: int = GameState.yard_slots.get_or_add(option.id, [-1, -1, -1, -1, -1])[i]
	if uid < 0:
		return {"title": "Empty", "blurb": "Place a Hearthling here to train it at the %s." % option.name}
	return {"title": "#%d" % uid, "blurb": ""}
