@tool
class_name ActivityDef extends Resource
## Installed in a Training Yard environment; each night it changes the creatures doing it.

@export var id: StringName
@export var name: String
@export var icon: Texture2D
@export var cost := 0
@export var stat_deltas: Dictionary[Types.Stat, float] = {}
@export var affinity_deltas: Dictionary[Types.Affinity, float] = {}
