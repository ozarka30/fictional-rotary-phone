@tool
class_name DoughDef extends Resource
## One portion of dough: which affinities the body has, and how high they can go.

@export var id: StringName
@export var name: String
@export var icon: Texture2D
@export var cost := 0
@export var affinity_caps: Dictionary[Types.Affinity, float] = {}
