class_name RetroAchievementsModal
extends Window

## RetroAchievements Badges, Points & Netplay Lobby Inspector Modal for Godot 4.7.

var _username_lbl: Label
var _score_lbl: Label
var _badges_container: HFlowContainer

func _init() -> void:
	title = "3DRetro - RetroAchievements & Online Netplay"
	size = Vector2i(550, 420)
	unresizable = true
	exclusive = true
	visible = false
	_build_ui()

func _build_ui() -> void:
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	margin.add_child(vbox)

	var title_lbl = Label.new()
	title_lbl.text = "🏆 RetroAchievements Profile & Badges"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 20)
	vbox.add_child(title_lbl)

	vbox.add_child(HSeparator.new())

	_username_lbl = Label.new()
	_username_lbl.text = "👤 Logged in as: PlayerOne (Master Rank)"
	_username_lbl.add_theme_font_size_override("font_size", 14)
	vbox.add_child(_username_lbl)

	_score_lbl = Label.new()
	_score_lbl.text = "⭐ Total Points: 1,480 PTS | Hardcore Score: 920 PTS"
	_score_lbl.modulate = Color(1.0, 0.82, 0.2)
	vbox.add_child(_score_lbl)

	var badge_hdr = Label.new()
	badge_hdr.text = "UNLOCKED BADGES:"
	badge_hdr.add_theme_font_size_override("font_size", 12)
	badge_hdr.modulate = Color(0.6, 0.6, 0.7)
	vbox.add_child(badge_hdr)

	_badges_container = HFlowContainer.new()
	_badges_container.add_theme_constant_override("h_separation", 10)
	_badges_container.add_theme_constant_override("v_separation", 10)
	vbox.add_child(_badges_container)

	var sample_badges = [
		"🥇 Master of SNES", "🥈 Boss Defeated", "🥉 100% Secret Unlocked",
		"🏆 Speedrunner 2026", "⭐ High Score 99999", "🕹️ Arcade Champion"
	]

	for badge_text in sample_badges:
		var badge_lbl = Label.new()
		badge_lbl.text = badge_text
		var sb = StyleBoxFlat.new()
		sb.bg_color = Color(0.12, 0.16, 0.25)
		sb.set_corner_radius_all(6)
		sb.content_margin_left = 10
		sb.content_margin_right = 10
		sb.content_margin_top = 6
		sb.content_margin_bottom = 6
		badge_lbl.add_theme_stylebox_override("normal", sb)
		_badges_container.add_child(badge_lbl)

	vbox.add_child(HSeparator.new())

	var close_btn = Button.new()
	close_btn.text = "Close Profile"
	close_btn.pressed.connect(hide)
	vbox.add_child(close_btn)

func open_modal(username: String = "PlayerOne") -> void:
	if username != "":
		_username_lbl.text = "👤 Logged in as: " + username + " (Master Rank)"
	popup_centered()
