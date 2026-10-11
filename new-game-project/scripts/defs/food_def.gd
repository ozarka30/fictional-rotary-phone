@tool
class_name FoodDef extends Resource
## Fed by hand. Every food has an upside, a downside and toxicity.

@export var id: StringName
@export var name: String
@export var icon: Texture2D
@export var cost := 0
@export var stat_deltas: Dictionary[Types.Stat, float] = {}
@export var affinity_deltas: Dictionary[Types.Affinity, float] = {}
@export var toxicity := 0.0
