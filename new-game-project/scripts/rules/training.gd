class_name Training
## Yards train settled Hearthlings overnight: each trained stat climbs toward its cap.

const PER_NIGHT := 6.0  # ponytail: tuned so the hunter's best line reaches C Knack in two nights

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
