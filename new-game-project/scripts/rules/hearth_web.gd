class_name HearthWeb
## The five-affinity web. Outer ring quells, inner star feeds.

const QUELLS := {
	Types.Affinity.EMBER: Types.Affinity.FROST,
	Types.Affinity.FROST: Types.Affinity.BLOOM,
	Types.Affinity.BLOOM: Types.Affinity.CLAY,
	Types.Affinity.CLAY: Types.Affinity.TIDE,
	Types.Affinity.TIDE: Types.Affinity.EMBER,
}
const FEEDS := {
	Types.Affinity.BLOOM: Types.Affinity.EMBER,
	Types.Affinity.EMBER: Types.Affinity.CLAY,
	Types.Affinity.CLAY: Types.Affinity.FROST,
	Types.Affinity.FROST: Types.Affinity.TIDE,
	Types.Affinity.TIDE: Types.Affinity.BLOOM,
}
const FEED_BONUS := 1.5     # ponytail: placeholder
const QUELL_PENALTY := 0.5  # ponytail: placeholder


## A food that feeds the pen's affinity is boosted; one that quells it is weakened.
static func modifier(food: Types.Affinity, pen: Types.Affinity) -> float:
	if FEEDS.get(food) == pen:
		return FEED_BONUS
	if QUELLS.get(food) == pen:
		return QUELL_PENALTY
	return 1.0
