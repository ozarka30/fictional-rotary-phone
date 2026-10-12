@tool
class_name ActivityDef extends Resource
## What a creature does in its Training Yard slot each night. Basic activities are always available;
## machines are bought, installed into one slot, and become an extra activity for that slot.

@export var id: StringName
@export var name: String
@export var icon: Texture2D
@export var cost := 0
@export var machine := false
@export var stat_deltas: Dictionary[Types.Stat, float] = {}
@export var affinity_deltas: Dictionary[Types.Affinity, float] = {}
