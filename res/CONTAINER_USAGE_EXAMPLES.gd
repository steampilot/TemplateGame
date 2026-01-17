## CONTAINER SYSTEM - USAGE EXAMPLES
## ===================================
## Diese Datei zeigt, wie das neue Container-System verwendet wird

# ===============================================
# 1. MAIN MENU LADEN (versteckt Level & HUD)
# ===============================================
func load_main_menu() -> void:
	SceneManager.load_into_container(
		SceneRegistry.main_scenes["StartScreen"],
		SceneManager.ContainerType.MENU,
		[SceneManager.ContainerType.LEVEL, SceneManager.ContainerType.HUD],
		"fade_to_black"
	)

# ===============================================
# 2. LEVEL STARTEN (versteckt Menu, zeigt HUD)
# ===============================================
func start_game_level() -> void:
	# Zuerst Level laden
	SceneManager.load_into_container(
		SceneRegistry.levels["game_start"],
		SceneManager.ContainerType.LEVEL,
		[SceneManager.ContainerType.MENU],  # Menu verstecken
		"fade_to_black"
	)
	
	# Dann HUD laden (ohne Transition)
	await SceneManager.load_complete
	SceneManager.load_into_container(
		"res://Scenes/UI/GameHUD.tscn",  # Beispiel-Pfad
		SceneManager.ContainerType.HUD,
		[],  # Nichts verstecken
		"no_transition"
	)

# ===============================================
# 3. SETTINGS MENU ÖFFNEN (alles bleibt sichtbar)
# ===============================================
func open_settings_overlay() -> void:
	SceneManager.load_into_container(
		"res://Scenes/Menus/settings_menu.tscn",
		SceneManager.ContainerType.MENU,
		[],  # Nichts verstecken - Settings als Overlay
		"fade_to_black"
	)

# ===============================================
# 4. CUTSCENE SPIELEN (nur Level sichtbar, HUD versteckt)
# ===============================================
func play_cutscene() -> void:
	SceneManager.load_into_container(
		"res://Scenes/Cutscenes/Intro.tscn",
		SceneManager.ContainerType.LEVEL,
		[SceneManager.ContainerType.HUD],  # HUD verstecken
		"fade_to_black"
	)

# ===============================================
# 5. LEVEL WECHSEL (HUD bleibt geladen)
# ===============================================
func change_level(level_path:String) -> void:
	SceneManager.load_into_container(
		level_path,
		SceneManager.ContainerType.LEVEL,
		[],  # Nichts verstecken - HUD bleibt sichtbar
		"fade_to_black"
	)

# ===============================================
# 6. DIREKTE CONTAINER VERWALTUNG
# ===============================================
func show_hide_containers_manually() -> void:
	# Direkte Sichtbarkeit über Main Scene
	var main = get_node("/root/Main") as Main
	if main:
		main.level_container.visible = true
		main.hud_container.visible = false
		main.menu_container.visible = true
