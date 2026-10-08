@tool
class_name HearthlingData extends Resource
## Everything about one Hearthling. Plain data; rules and components change it.

@export var uid: int
@export var egg: EggDef
@export var family_id: StringName
@export var form_affinity := Types.Affinity.NONE  # set at stabilization
@export var stabilized := false
@export var malleable_days_left := 0

@export var stats: Dictionary[Types.Stat, float] = {}
@export var potentials: Dictionary[Types.Stat, float] = {}
@export var affinities: Dictionary[Types.Affinity, float] = {}
@export var conditions: Array[StringName] = []
@export var traits: Array[StringName] = []
@export var skills: Array[StringName] = []
@export var quality := Types.Grade.E

@export var pen_id: StringName
@export var fed_today := false
@export var acted_today := false
@export var rested_today := false
@export var idle_streak := 0
@export var history: Array[DayEntry] = []  # food, action, pen per day; becomes the recipe later


func stat_grade(stat: Types.Stat) -> Types.Grade:
	return Types.grade_of(stats.get(stat, 0.0))


func affinity_grade(affinity: Types.Affinity) -> Types.Grade:
	return Types.grade_of(affinities.get(affinity, 0.0))
