class_name Training
## The only place stats are trained: each night, a Hearthling in a yard gains in that yard's stats, up to its caps.
## Only settled Hearthlings train; shaping is food and environment only.

const PER_NIGHT := 15.0  # ponytail: tuned so the hunter's pup goes 10 -> C Knack (40) in its 2 settled nights

# ponytail: yards as consts until they need costs, unlocks or art (then a YardDef in data/yards)
const YARDS := [
	{"id": &"obstacle_run", "name": "Obstacle Run", "stats": [Types.Stat.PACE, Types.Stat.BRAWN]},
	{"id": &"scent_trail", "name": "Scent Trail", "stats": [Types.Stat.KNACK, Types.Stat.WITS]},
	{"id": &"sparring_ring", "name": "Sparring Ring", "stats": [Types.Stat.GRIT, Types.Stat.BRAWN]},
	{"id": &"calm_garden", "name": "Calm Garden", "stats": [Types.Stat.HEART, Types.Stat.WITS]},
]


static func train(h: HearthlingData, stats: Array) -> void:
	if not h.stabilized:
		return
	for s in stats:
		h.stats[s] = minf(h.stats.get(s, 0.0) + PER_NIGHT, h.potentials.get(s, 0.0))
