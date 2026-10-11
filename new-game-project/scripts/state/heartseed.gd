@tool
class_name Heartseed extends Resource
## The soul. Holds every bit of exp a Hearthling has earned and moves with it between bodies.
## A .tres of one (the Null Heartseed) is also what the Market sells: buying duplicates it.

@export var uid: int
@export var id: StringName
@export var name: String
@export var cost := 0
@export var stat_exp: Dictionary[Types.Stat, float] = {}
@export var affinity_exp: Dictionary[Types.Affinity, float] = {}
@export var traits: Array[StringName] = []
