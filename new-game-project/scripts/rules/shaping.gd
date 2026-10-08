class_name Shaping
## The shaping-window rules: one food a day, the pen's environment pushes overnight.
## (Stat training happens in the Training Yard, see Training.)
## Pure functions on HearthlingData, so the workbench can preview on a copy.


static func feed(h: HearthlingData, food: FoodDef, pen: PenDef) -> void:
	for a in food.affinity_deltas:
		_add_affinity(h, a, food.affinity_deltas[a] * HearthWeb.modifier(a, pen.affinity))
	_add_potentials(h, food.potential_deltas)
	_add_stats(h, food.stat_deltas)


## Today's food, once, from the workbench.
static func give_food(h: HearthlingData, food: FoodDef, pen: PenDef) -> void:
	feed(h, food, pen)
	h.fed_today = true


static func can_shape(h: HearthlingData) -> bool:
	return not h.stabilized and h.malleable_days_left > 0


## Overnight pen push, idle tracking, one malleable day used up.
static func night(h: HearthlingData, pen: PenDef) -> void:
	if pen.affinity != Types.Affinity.NONE:
		_add_affinity(h, pen.affinity, pen.push_per_day)
	h.idle_streak = 0 if h.fed_today else h.idle_streak + 1
	h.malleable_days_left = maxi(h.malleable_days_left - 1, 0)


## Overnight for one Hearthling. True if it settled tonight.
static func end_day(h: HearthlingData, pen: PenDef) -> bool:
	var settled := false
	if can_shape(h):
		night(h, pen)
		if h.malleable_days_left == 0:
			h.stabilized = true  # ponytail: form, traits and skills lock in here later
			settled = true
	h.fed_today = false
	return settled


## What `h` would look like after this food (may be null) in this pen tonight.
static func preview(h: HearthlingData, food: FoodDef, pen: PenDef) -> HearthlingData:
	var p: HearthlingData = h.duplicate()
	p.stats = h.stats.duplicate()
	p.potentials = h.potentials.duplicate()
	p.affinities = h.affinities.duplicate()
	if food:
		feed(p, food, pen)
	if can_shape(p) and pen.affinity != Types.Affinity.NONE:
		_add_affinity(p, pen.affinity, pen.push_per_day)
	return p


static func _add_affinity(h: HearthlingData, a: Types.Affinity, amount: float) -> void:
	h.affinities[a] = clampf(h.affinities.get(a, 0.0) + amount, 0.0, Types.MAX_VALUE)


static func _add_potentials(h: HearthlingData, deltas: Dictionary) -> void:
	for s in deltas:
		h.potentials[s] = clampf(h.potentials.get(s, 0.0) + deltas[s], 0.0, Types.MAX_VALUE)


static func _add_stats(h: HearthlingData, deltas: Dictionary) -> void:
	for s in deltas:
		h.stats[s] = clampf(h.stats.get(s, 0.0) + deltas[s], 0.0, h.potentials.get(s, 0.0))
