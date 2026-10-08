class_name Shaping
## The shaping-window rules: one food and one action a day, the pen pushes overnight.
## Pure functions on HearthlingData, so the panel can preview on a copy.


static func feed(h: HearthlingData, food: FoodDef, pen: PenDef) -> void:
	for a in food.affinity_deltas:
		_add_affinity(h, a, food.affinity_deltas[a] * HearthWeb.modifier(a, pen.affinity))
	_add_potentials(h, food.potential_deltas)
	_add_stats(h, food.stat_deltas)


static func act(h: HearthlingData, action: ActionDef) -> void:
	_add_potentials(h, action.potential_deltas)
	_add_stats(h, action.stat_deltas)


## Overnight: pen push, idle tracking, one malleable day used up.
static func night(h: HearthlingData, pen: PenDef, rested: bool) -> void:
	if pen.affinity != Types.Affinity.NONE:
		_add_affinity(h, pen.affinity, pen.push_per_day)
	h.idle_streak = h.idle_streak + 1 if rested or not (h.fed_today or h.acted_today) else 0
	h.malleable_days_left = maxi(h.malleable_days_left - 1, 0)


## Today's food / action, once each, from the workbench.
static func give_food(h: HearthlingData, food: FoodDef, pen: PenDef) -> void:
	feed(h, food, pen)
	h.fed_today = true


static func give_action(h: HearthlingData, action: ActionDef) -> void:
	act(h, action)
	h.acted_today = true
	h.rested_today = action.is_rest


static func can_shape(h: HearthlingData) -> bool:
	return not h.stabilized and h.malleable_days_left > 0


## Overnight for one Hearthling. True if it settled tonight.
static func end_day(h: HearthlingData, pen: PenDef) -> bool:
	var settled := false
	if can_shape(h):
		night(h, pen, h.rested_today)
		if h.malleable_days_left == 0:
			h.stabilized = true  # ponytail: form, traits and skills lock in here later
			settled = true
	h.fed_today = false
	h.acted_today = false
	h.rested_today = false
	return settled


## What `h` would look like after this food and action (either may be null).
static func preview(h: HearthlingData, food: FoodDef, action: ActionDef, pen: PenDef) -> HearthlingData:
	var p: HearthlingData = h.duplicate()
	p.stats = h.stats.duplicate()
	p.potentials = h.potentials.duplicate()
	p.affinities = h.affinities.duplicate()
	if food:
		feed(p, food, pen)
	if action:
		act(p, action)
	return p


static func _add_affinity(h: HearthlingData, a: Types.Affinity, amount: float) -> void:
	h.affinities[a] = clampf(h.affinities.get(a, 0.0) + amount, 0.0, Types.MAX_VALUE)


static func _add_potentials(h: HearthlingData, deltas: Dictionary) -> void:
	for s in deltas:
		h.potentials[s] = clampf(h.potentials.get(s, 0.0) + deltas[s], 0.0, Types.MAX_VALUE)


static func _add_stats(h: HearthlingData, deltas: Dictionary) -> void:
	for s in deltas:
		h.stats[s] = clampf(h.stats.get(s, 0.0) + deltas[s], 0.0, h.potentials.get(s, 0.0))
