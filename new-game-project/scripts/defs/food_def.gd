class_name FoodDef extends Resource

@export var id: StringName
@export var name: String
@export var icon: Texture2D
@export var cost := 0
@export var affinity_deltas: Dictionary[Types.Affinity, float] = {}
@export var potential_deltas: Dictionary[Types.Stat, float] = {}
@export var stat_deltas: Dictionary[Types.Stat, float] = {}
