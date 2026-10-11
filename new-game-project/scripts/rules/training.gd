class_name Training
## Growth after baking: nights in a Training Yard environment, and food fed by hand.
## Gains stop at the body's caps; losses stop at 0. Everything lands on the Heartseed.

const TOXICITY_MAX := 100.0  # ponytail: nothing lowers toxicity yet, so food is a budget per creature


static func apply(h: HearthlingData, stat_deltas: Dictionary, affinity_deltas: Dictionary) -> void:
	for s in stat_deltas:
		h.seed.stat_exp[s] = _step(h.seed.stat_exp.get(s, 0.0), stat_deltas[s], h.stat_caps.get(s, 0.0))
	for a in affinity_deltas:
		h.seed.affinity_exp[a] = _step(h.seed.affinity_exp.get(a, 0.0), affinity_deltas[a], h.affinity_caps.get(a, 0.0))


## One night: the environment's effect plus the activity's (activity may be null).
static func night(h: HearthlingData, env: EnvDef, activity: ActivityDef) -> void:
	apply(h, env.stat_deltas, env.affinity_deltas)
	if activity:
		apply(h, activity.stat_deltas, activity.affinity_deltas)


static func can_feed(h: HearthlingData) -> bool:
	return h.toxicity < TOXICITY_MAX


static func feed(h: HearthlingData, food: FoodDef) -> bool:
	if not can_feed(h):
		return false
	h.toxicity = minf(h.toxicity + food.toxicity, TOXICITY_MAX)
	apply(h, food.stat_deltas, food.affinity_deltas)
	return true


static func _step(value: float, delta: float, cap: float) -> float:
	if delta < 0.0:
		return maxf(value + delta, 0.0)
	return maxf(value, minf(value + delta, cap))  # exp already past the cap stays, but doesn't grow
