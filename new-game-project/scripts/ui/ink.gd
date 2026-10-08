class_name Ink
## BBCode helpers for the comic look: colored, ink-outlined text and chunky grade letters.

const GRADE_FONT := "res://art/fonts/Mastro-Regular.ttf"


static func chip(text: String, color: Color) -> String:
	return "[outline_size=5][outline_color=#181818][color=#%s]%s[/color][/outline_color][/outline_size]" % [color.to_html(false), text]


static func grade(g: Types.Grade, suffix := "", size := 26) -> String:
	return "[font=%s][font_size=%d]%s%s[/font_size][/font]" % [GRADE_FONT, size, Types.grade_name(g), suffix]
