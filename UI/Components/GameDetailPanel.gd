class_name GameDetailPanel
extends PanelContainer

## Right Game Detail Panel in GDScript with High-Fidelity Cover Banners, Neon Play Button, and Achievements.

signal launch_requested(game_id: String)
signal favorite_toggled(game_id: String)
signal metadata_download_requested(game_id: String)

const VideoSnapPlayerScript = preload("res://UI/Components/VideoSnapPlayer.gd")

var _cover_banner: TextureRect
var _video_snap
var _title_lbl: Label
var _platform_lbl: Label
var _developer_lbl: Label
var _genre_rating_lbl: Label
var _description_lbl: RichTextLabel
var _playtime_lbl: Label
var _achievements_lbl: Label

var _play_btn: Button
var _fav_btn: Button
var _meta_btn: Button
var _current_game: Dictionary = {}

func _init() -> void:
	custom_minimum_size = Vector2(380, 0)
	_build_ui()

func apply_theme_colors(colors: Dictionary) -> void:
	var accent = colors.get("accent", Color(0.0, 0.85, 0.95))
	var sec_accent = colors.get("accent_secondary", Color(1.0, 0.82, 0.2))
	var surface = colors.get("surface", Color(0.10, 0.11, 0.18, 0.92))
	var text_col = colors.get("text", Color(1.0, 1.0, 1.0))
	var border_col = colors.get("border_color", accent.darkened(0.5))

	var panel_sb = StyleBoxFlat.new()
	panel_sb.bg_color = surface
	panel_sb.set_corner_radius_all(8)
	panel_sb.border_width_left = 1
	panel_sb.border_width_top = 1
	panel_sb.border_width_right = 1
	panel_sb.border_width_bottom = 1
	panel_sb.border_color = border_col
	add_theme_stylebox_override("panel", panel_sb)

	if _title_lbl:
		_title_lbl.add_theme_color_override("font_color", text_col)
	if _platform_lbl:
		_platform_lbl.modulate = accent
	if _developer_lbl:
		_developer_lbl.add_theme_color_override("font_color", text_col)
	if _genre_rating_lbl:
		_genre_rating_lbl.modulate = sec_accent
	if _description_lbl:
		_description_lbl.add_theme_color_override("default_color", text_col)
	if _playtime_lbl:
		_playtime_lbl.add_theme_color_override("font_color", text_col)
	if _achievements_lbl:
		_achievements_lbl.add_theme_color_override("font_color", text_col)

	if _play_btn:
		_play_btn.add_theme_color_override("font_color", Color(0.05, 0.05, 0.05) if accent.get_luminance() > 0.55 else Color(1, 1, 1))
		var play_sb = StyleBoxFlat.new()
		play_sb.bg_color = accent
		play_sb.set_corner_radius_all(8)
		play_sb.shadow_color = Color(accent.r, accent.g, accent.b, 0.6)
		play_sb.shadow_size = 12
		_play_btn.add_theme_stylebox_override("normal", play_sb)

		var play_hover = StyleBoxFlat.new()
		play_hover.bg_color = accent.lightened(0.18)
		play_hover.set_corner_radius_all(8)
		play_hover.shadow_color = Color(accent.r, accent.g, accent.b, 0.85)
		play_hover.shadow_size = 16
		_play_btn.add_theme_stylebox_override("hover", play_hover)

	if _fav_btn:
		_fav_btn.add_theme_color_override("font_color", text_col)
		var fav_sb = StyleBoxFlat.new()
		fav_sb.bg_color = surface.lightened(0.08)
		fav_sb.border_width_left = 1
		fav_sb.border_width_top = 1
		fav_sb.border_width_right = 1
		fav_sb.border_width_bottom = 1
		fav_sb.border_color = sec_accent
		fav_sb.set_corner_radius_all(6)
		_fav_btn.add_theme_stylebox_override("normal", fav_sb)

	if _meta_btn:
		_meta_btn.add_theme_color_override("font_color", text_col)
		var meta_sb = StyleBoxFlat.new()
		meta_sb.bg_color = surface.lightened(0.08)
		meta_sb.border_width_left = 1
		meta_sb.border_width_top = 1
		meta_sb.border_width_right = 1
		meta_sb.border_width_bottom = 1
		meta_sb.border_color = accent.darkened(0.3)
		meta_sb.set_corner_radius_all(6)
		_meta_btn.add_theme_stylebox_override("normal", meta_sb)

func _build_ui() -> void:
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	add_child(margin)

	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	margin.add_child(scroll)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	scroll.add_child(vbox)

	# Cover / Trailer Banner
	_cover_banner = TextureRect.new()
	_cover_banner.custom_minimum_size = Vector2(345, 190)
	_cover_banner.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_cover_banner.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	vbox.add_child(_cover_banner)

	_video_snap = VideoSnapPlayerScript.new()
	vbox.add_child(_video_snap)

	_title_lbl = Label.new()
	_title_lbl.text = "Select a Game"
	_title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_lbl.add_theme_font_size_override("font_size", 24)
	vbox.add_child(_title_lbl)

	_platform_lbl = Label.new()
	_platform_lbl.text = "Platform: --"
	_platform_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_platform_lbl.modulate = Color(0.0, 0.85, 0.95) # Cyan Accent
	vbox.add_child(_platform_lbl)

	_developer_lbl = Label.new()
	_developer_lbl.text = "Developer: --"
	_developer_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_developer_lbl)

	_genre_rating_lbl = Label.new()
	_genre_rating_lbl.text = "Genre: -- | Rating: ★★★★★"
	_genre_rating_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_genre_rating_lbl.modulate = Color(1.0, 0.82, 0.2) # Gold Stars
	vbox.add_child(_genre_rating_lbl)

	vbox.add_child(HSeparator.new())

	var desc_hdr = Label.new()
	desc_hdr.text = "OVERVIEW:"
	desc_hdr.add_theme_font_size_override("font_size", 12)
	desc_hdr.modulate = Color(0.6, 0.6, 0.7)
	vbox.add_child(desc_hdr)

	_description_lbl = RichTextLabel.new()
	_description_lbl.custom_minimum_size = Vector2(0, 100)
	_description_lbl.bbcode_enabled = true
	_description_lbl.text = "Select a game from the library grid to view details."
	vbox.add_child(_description_lbl)

	vbox.add_child(HSeparator.new())

	_playtime_lbl = Label.new()
	_playtime_lbl.text = "🕒 Total Playtime: 0 mins"
	vbox.add_child(_playtime_lbl)

	_achievements_lbl = Label.new()
	_achievements_lbl.text = "🏆 RetroAchievements: 2 / 4 Unlocked (35 Pts)"
	vbox.add_child(_achievements_lbl)

	# Big Glowing Neon Play Button
	_play_btn = Button.new()
	_play_btn.text = "▶  PLAY GAME"
	_play_btn.custom_minimum_size = Vector2(0, 52)
	_play_btn.add_theme_font_size_override("font_size", 18)
	var play_sb = StyleBoxFlat.new()
	play_sb.bg_color = Color(0.0, 0.75, 0.90)
	play_sb.set_corner_radius_all(8)
	play_sb.shadow_color = Color(0.0, 0.85, 0.95, 0.5)
	play_sb.shadow_size = 10
	_play_btn.add_theme_stylebox_override("normal", play_sb)
	_play_btn.pressed.connect(func(): if _current_game.has("id"): launch_requested.emit(_current_game["id"]))
	vbox.add_child(_play_btn)

	_fav_btn = Button.new()
	_fav_btn.text = "★ Add to Favorites"
	_fav_btn.custom_minimum_size = Vector2(0, 38)
	_fav_btn.pressed.connect(func(): if _current_game.has("id"): favorite_toggled.emit(_current_game["id"]))
	vbox.add_child(_fav_btn)

	_meta_btn = Button.new()
	_meta_btn.text = "🌐 Download Online Metadata"
	_meta_btn.custom_minimum_size = Vector2(0, 34)
	_meta_btn.pressed.connect(func(): if _current_game.has("id"): metadata_download_requested.emit(_current_game["id"]))
	vbox.add_child(_meta_btn)

func display_game_details(game: Dictionary) -> void:
	_current_game = game
	var title = game.get("title", "Select a Game")
	var plat = str(game.get("platform", "--")).to_upper()
	_title_lbl.text = title
	_platform_lbl.text = "Platform: " + plat
	_developer_lbl.text = "Developer: " + game.get("developer", "Unknown")
	_genre_rating_lbl.text = "Genre: " + game.get("genre", "Classic") + " | Rating: ★★★★★"
	_description_lbl.text = game.get("synopsis", game.get("description", "No description available."))
	_playtime_lbl.text = "🕒 Total Playtime: " + str(game.get("total_play_time", game.get("playtime", 0))) + " mins"
	_fav_btn.text = "★ Favorited" if game.get("is_favorite", false) else "☆ Add to Favorites"
	
	_cover_banner.texture = _generate_banner_texture(title, plat)
	if _video_snap and _video_snap.has_method("load_game_preview"):
		_video_snap.load_game_preview(game)

func _generate_banner_texture(title: String, plat: String) -> Texture2D:
	var grad = Gradient.new()
	grad.colors = PackedColorArray([Color(0.15, 0.25, 0.45), Color(0.04, 0.05, 0.12)])
	var tex = GradientTexture2D.new()
	tex.gradient = grad
	tex.fill_from = Vector2(0, 0)
	tex.fill_to = Vector2(1, 1)
	tex.width = 345
	tex.height = 190
	return tex
