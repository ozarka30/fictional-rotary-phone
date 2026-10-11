class_name Ink
## BBCode helpers for the comic look: colored, ink-outlined text and chunky grade letters.

const GRADE_FONT := "res://art/fonts/Mastro-Regular.ttf"


static func chip(text: String, color: Color) -> String:
	return "[outline_size=5][outline_color=#181818][color=#%s]%s[/color][/outline_color][/outline_size]" % [color.to_html(false), text]


static func grade(g: Types.Grade, suffix := "", size := 26) -> String:
	return "[font=%s][font_size=%d]%s%s[/font_size][/font]" % [GRADE_FONT, size, Types.grade_name(g), suffix]


## One line of colored effects for any shop def: mold slots and caps, dough and mix-in caps, food and activity deltas.
static func effects(def: Resource) -> String:
	var bits := PackedStringArray()
	if def is MoldDef:
		bits.append("%d dough, %d mix-in" % [def.dough_slots, def.mixin_slots])
		for s in def.stat_caps:
			bits.append(chip("%s %s" % [Types.Stat.keys()[s].capitalize(), grade(Types.grade_of(def.stat_caps[s]), "", 18)], Types.STAT_COLORS[s]))
		if def.traits:
			bits.append(", ".join(def.traits.map(func(t): return String(t).capitalize())))
		bits.append("unlimited uses" if def.uses < 0 else "%d uses" % def.uses)
		return ", ".join(bits)
	if def is Heartseed:
		return "A blank soul: 0 in everything. Bake it into a body."
	var suffix := " cap" if def is DoughDef or def is MixinDef else ""
	for key in [&"stat_caps", &"stat_deltas"]:
		var d = def.get(key)
		if d:
			for s in d:
				bits.append(chip("%+d %s%s" % [d[s], Types.Stat.keys()[s].capitalize(), suffix], Types.STAT_COLORS[s]))
	for key in [&"affinity_caps", &"affinity_deltas"]:
		var d = def.get(key)
		if d:
			for a in d:
				bits.append(chip("%+d %s%s" % [d[a], Types.Affinity.keys()[a].capitalize(), suffix], Types.AFFINITY_COLORS[a]))
	if def.get(&"dough_slots"):
		bits.append("%+d dough slot" % def.dough_slots)
	if def.get(&"toxicity"):
		bits.append("%d toxicity" % def.toxicity)
	if def.get(&"rare"):
		bits.append("rare")
	return ", ".join(bits)


## BBCode tags stripped, for plain Buttons.
static func plain(text: String) -> String:
	var re := RegEx.create_from_string("\\[[^\\]]*\\]")
	return re.sub(text, "", true)
