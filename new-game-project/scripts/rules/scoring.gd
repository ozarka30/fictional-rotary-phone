class_name Scoring
## How happy a customer is with a Hearthling: 1 star if any minimum is missed,
## otherwise 3, plus one per grade above a minimum, up to 5.


static func meets(h: HearthlingData, r: RequestDef) -> bool:
	for s in r.min_stats:
		if h.stat_grade(s) < r.min_stats[s]:
			return false
	for a in r.min_affinities:
		if h.affinity_grade(a) < r.min_affinities[a]:
			return false
	return true


static func stars(h: HearthlingData, r: RequestDef) -> int:
	if not meets(h, r):
		return 1
	var margin := 0
	for s in r.min_stats:
		margin += h.stat_grade(s) - r.min_stats[s]
	for a in r.min_affinities:
		margin += h.affinity_grade(a) - r.min_affinities[a]
	return mini(3 + margin, 5)
