class_name Types
## Shared enums and grade math. Values are 0-100 under the hood, shown as grades.

enum Stat { BRAWN, PACE, GRIT, WITS, HEART, KNACK }
enum Affinity { NONE, EMBER, FROST, BLOOM, CLAY, TIDE }
enum Grade { E, D, C, B, A, S }

const MAX_VALUE := 100.0

# UI colors, from the palette swatch
const STAT_COLORS := {
	Stat.BRAWN: Color("e1402b"), Stat.PACE: Color("faa612"), Stat.GRIT: Color("c1b87a"),
	Stat.WITS: Color("7462a4"), Stat.HEART: Color("fb54ab"), Stat.KNACK: Color("ba5bb1"),
}
const AFFINITY_COLORS := {
	Affinity.EMBER: Color("f17135"), Affinity.FROST: Color("95c4d7"), Affinity.BLOOM: Color("5ec17f"),
	Affinity.CLAY: Color("8d8b37"), Affinity.TIDE: Color("13aaaa"),
}
const DAYS_COLOR := Color("dee2e6")
const COIN_COLOR := Color("fdcd01")
const GRADE_FLOORS := [0.0, 20.0, 40.0, 60.0, 75.0, 90.0]  # ponytail: placeholder bands, tune in playtests


static func grade_of(value: float) -> Grade:
	for i in range(GRADE_FLOORS.size() - 1, -1, -1):
		if value >= GRADE_FLOORS[i]:
			return i as Grade
	return Grade.E


static func grade_name(grade: Grade) -> String:
	return Grade.keys()[grade]


## Lowest value that counts as `grade`, for "C or better" checks.
static func floor_of(grade: Grade) -> float:
	return GRADE_FLOORS[grade]
