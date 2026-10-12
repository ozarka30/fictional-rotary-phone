@tool
class_name HearthlingData extends Resource
## One baked Hearthling: a body (mold, dough, mix-ins) around a Heartseed.
## What shows is the seed's exp, capped by the body.

@export var uid: int
@export var name: String
@export var mold: MoldDef
@export var doughs: Array[DoughDef] = []
@export var mixins: Array[MixinDef] = []
@export var seed: Heartseed
@export var stat_caps: Dictionary[Types.Stat, float] = {}
@export var affinity_caps: Dictionary[Types.Affinity, float] = {}
@export var toxicity := 0.0


func stat(s: Types.Stat) -> float:
	return minf(seed.stat_exp.get(s, 0.0), stat_caps.get(s, 0.0))


func affinity(a: Types.Affinity) -> float:
	return minf(seed.affinity_exp.get(a, 0.0), affinity_caps.get(a, 0.0))


func stat_grade(s: Types.Stat) -> Types.Grade:
	return Types.grade_of(stat(s))


func affinity_grade(a: Types.Affinity) -> Types.Grade:
	return Types.grade_of(affinity(a))


func traits() -> Array[StringName]:
	return mold.traits + seed.traits
