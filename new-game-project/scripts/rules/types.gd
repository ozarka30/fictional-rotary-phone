class_name Types
## Shared enums and grade math. Values are 0-100 under the hood, shown as grades.

enum Stat { BRAWN, PACE, GRIT, WITS, HEART, KNACK }
enum Affinity { NONE, EMBER, FROST, BLOOM, CLAY, TIDE }
enum Grade { E, D, C, B, A, S }

const MAX_VALUE := 100.0
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
