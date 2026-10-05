@tool
extends McpTestSuite
## Run from Claude via test_run, or the Godot AI dock.


func suite_name() -> String:
	return "rules"


func test_grade_bands() -> void:
	assert_eq(Types.grade_of(0.0), Types.Grade.E)
	assert_eq(Types.grade_of(39.9), Types.Grade.D)
	assert_eq(Types.grade_of(40.0), Types.Grade.C)
	assert_eq(Types.grade_of(100.0), Types.Grade.S)


func test_hearth_web() -> void:
	assert_eq(HearthWeb.modifier(Types.Affinity.TIDE, Types.Affinity.BLOOM), HearthWeb.FEED_BONUS)
	assert_eq(HearthWeb.modifier(Types.Affinity.TIDE, Types.Affinity.EMBER), HearthWeb.QUELL_PENALTY)
	assert_eq(HearthWeb.modifier(Types.Affinity.TIDE, Types.Affinity.TIDE), 1.0)


func test_hunter_request_loads() -> void:
	var req: RequestDef = load("res://data/requests/hunter_tracker.tres")
	assert_eq(req.min_stats[Types.Stat.KNACK], Types.Grade.C)
	assert_eq(req.egg.malleable_days, 3)
	assert_eq(req.intro_dialog.lines.size(), 6)  # defs are @tool so the editor keeps real values



func test_hatch_basic_egg() -> void:
	var egg: EggDef = load("res://data/eggs/basic_egg.tres")
	var h := Hatching.hatch(egg, load("res://data/families/pup.tres"), 7)
	assert_eq(h.uid, 7)
	assert_eq(h.malleable_days_left, 3)
	assert_eq(h.stats.size(), Types.Stat.size())
	assert_eq(h.potentials[Types.Stat.KNACK], 40.0)


## The hunter's best line: Brine fish x2 + Sniff-and-find x3 in the wash basin.
func test_shaping_hunter_line() -> void:
	var h := Hatching.hatch(load("res://data/eggs/basic_egg.tres"), load("res://data/families/pup.tres"), 1)
	var fish: FoodDef = load("res://data/foods/brine_fish.tres")
	var sniff: ActionDef = load("res://data/actions/sniff_and_find.tres")
	var basin: PenDef = load("res://data/pens/wash_basin.tres")
	for day in 3:
		if day < 2:
			Shaping.feed(h, fish, basin)
		Shaping.act(h, sniff)
		Shaping.night(h, basin, false)
	assert_eq(h.malleable_days_left, 0)
	assert_eq(h.affinity_grade(Types.Affinity.TIDE), Types.Grade.D)  # 24 + 15 = 39, just shy of C
	assert_eq(h.stats[Types.Stat.KNACK], 28.0)                        # training closes the gap to C
	assert_eq(h.potentials[Types.Stat.KNACK], 55.0)


func test_preview_leaves_original() -> void:
	var h := Hatching.hatch(load("res://data/eggs/basic_egg.tres"), load("res://data/families/pup.tres"), 1)
	var p := Shaping.preview(h, load("res://data/foods/brine_fish.tres"), null, load("res://data/pens/basic_pen.tres"))
	assert_eq(p.affinities[Types.Affinity.TIDE], 12.0)
	assert_false(h.affinities.has(Types.Affinity.TIDE))
