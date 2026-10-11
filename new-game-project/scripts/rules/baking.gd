class_name Baking
## Mold + dough + mix-ins + Heartseed -> a Hearthling. Pure, so tests can call it without autoloads.

const FRESH_AFFINITY := 0.25  # a fresh bake starts each affinity at this share of its cap
const REMOLD_KEEP := 0.85     # share of exp a Heartseed keeps when taken out of its body


static func dough_slots(mold: MoldDef, mixins: Array) -> int:
	var n := mold.dough_slots
	for m: MixinDef in mixins:
		n += m.dough_slots
	return n


## Caps for this recipe: {"stats": {Stat: cap}, "affinities": {Affinity: cap}}.
static func caps(mold: MoldDef, doughs: Array, mixins: Array) -> Dictionary:
	var stats := {}
	var affs := {}
	for s in Types.Stat.values():
		stats[s] = mold.stat_caps.get(s, 0.0)
	for d: DoughDef in doughs:
		for a in d.affinity_caps:
			affs[a] = affs.get(a, 0.0) + d.affinity_caps[a]
	for m: MixinDef in mixins:
		for s in m.stat_caps:
			stats[s] = maxf(stats[s] + m.stat_caps[s], 0.0)
		for a in m.affinity_caps:
			affs[a] = maxf(affs.get(a, 0.0) + m.affinity_caps[a], 0.0)
	return {"stats": stats, "affinities": affs}


## Empty if the recipe can be baked, otherwise what's missing.
static func check(mold: MoldDef, doughs: Array, mixins: Array, seed: Heartseed) -> String:
	if mold == null:
		return "Choose a mold."
	if mixins.size() > mold.mixin_slots:
		return "Too many mix-ins."
	if doughs.size() != dough_slots(mold, mixins):
		return "This mold needs %d dough." % dough_slots(mold, mixins)
	if seed == null:
		return "Choose a Heartseed."
	return ""


static func bake(uid: int, mold: MoldDef, doughs: Array, mixins: Array, seed: Heartseed) -> HearthlingData:
	var c := caps(mold, doughs, mixins)
	var h := HearthlingData.new()
	h.uid = uid
	h.name = "%s #%d" % [mold.creature_name, uid]
	h.mold = mold
	h.doughs.assign(doughs)
	h.mixins.assign(mixins)
	h.seed = seed
	h.stat_caps.assign(c.stats)
	h.affinity_caps.assign(c.affinities)
	for a in c.affinities:
		seed.affinity_exp[a] = maxf(seed.affinity_exp.get(a, 0.0), c.affinities[a] * FRESH_AFFINITY)
	return h


## Takes the Heartseed out; the body (mold use, dough, mix-ins) is lost and the seed keeps most of its exp.
static func remold(h: HearthlingData) -> Heartseed:
	var seed := h.seed
	for s in seed.stat_exp:
		seed.stat_exp[s] *= REMOLD_KEEP
	for a in seed.affinity_exp:
		seed.affinity_exp[a] *= REMOLD_KEEP
	return seed
