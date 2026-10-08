@tool
class_name LedgerEntry extends InkRow
## One ledger line: the customer's portrait and a strip with their request.


func show_request(r: RequestDef, active: ActiveRequest = null) -> void:
	var portrait: Texture2D = r.intro_dialog.portrait if r.intro_dialog else null
	$Portrait.art = portrait
	%Initial.text = r.customer_name.left(1) if portrait == null else ""  # ponytail: initial until portraits exist
	var needs := PackedStringArray()
	for s in r.min_stats:
		needs.append(Ink.chip("%s %s" % [Types.Stat.keys()[s].capitalize(), Ink.grade(r.min_stats[s], "+", 22)], Types.STAT_COLORS[s]))
	for a in r.min_affinities:
		needs.append(Ink.chip("%s %s" % [Types.Affinity.keys()[a].capitalize(), Ink.grade(r.min_affinities[a], "+", 22)], Types.AFFINITY_COLORS[a]))
	var when := "Back in %d days" % r.return_after_days
	if active:
		var left := active.due_day - GameState.day
		when = "Due today" if left <= 0 else "Due day %d (%d left)" % [active.due_day, left]
	%Text.text = "[font_size=26]%s[/font_size]  %s\nNeeds: %s\n%s  -  Reward: %s" % [r.customer_name, r.summary, ", ".join(needs),
		Ink.chip(when, Types.DAYS_COLOR), Ink.chip("%d coin" % r.reward_coin, Types.COIN_COLOR)]


func show_message(msg: String) -> void:
	$Portrait.art = null
	%Initial.text = ""
	%Text.text = msg
