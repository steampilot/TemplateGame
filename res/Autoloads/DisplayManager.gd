extends Node
## DisplayManager - Integer Scaling for Pixel Art
## Manages window size and fullscreen with pixel-perfect integer scaling

# ============================================================
# STATE MACHINE
# ============================================================

enum State {
	WINDOWED,     ## Fixed window size with integer scale
	FULLSCREEN    ## Fullscreen with calculated integer scale
}

var current_state:State = State.WINDOWED

# ============================================================
# CONSTANTS
# ============================================================

const BASE_WIDTH:int = 640   ## Native viewport width
const BASE_HEIGHT:int = 360  ## Native viewport height

## Available window sizes (integer multipliers)
const WINDOW_SCALES:Array[int] = [2, 3, 4, 6]  # 1x too small, 2x=720p, 3x=1080p, 4x=1440p, 6x=4K

# ============================================================
# VARIABLES
# ============================================================

var current_window_scale:int = 2  ## Current scale factor in windowed mode (default: 2x = 1280×720)
var _config_path:String = "user://display_settings.cfg"  ## Config file for settings

# ============================================================
# LIFECYCLE
# ============================================================

func _ready() -> void:
	_load_settings()
	_initialize_display()
	_change_state(State.WINDOWED)

# ============================================================
# STATE MACHINE
# ============================================================

func _change_state(new_state:State) -> void:
	if current_state == new_state:
		return
		
	# Exit current state
	match current_state:
		State.WINDOWED:
			_state_exit_windowed()
		State.FULLSCREEN:
			_state_exit_fullscreen()
	
	# Change state
	var old_state = current_state
	current_state = new_state
	
	# Enter new state
	match current_state:
		State.WINDOWED:
			_state_entry_windowed()
		State.FULLSCREEN:
			_state_entry_fullscreen()
	
	print("DisplayManager: %s → %s" % [State.keys()[old_state], State.keys()[new_state]])

func _state_entry_windowed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	set_window_scale(current_window_scale)
	if not _is_editor_embedded():
		_center_window()

func _state_exit_windowed() -> void:
	pass  # Cleanup if needed

func _state_entry_fullscreen() -> void:
	# Check if running in editor embedded mode
	if _is_editor_embedded():
		push_warning("DisplayManager: Fullscreen not available in editor embedded mode. Run as standalone window or export game.")
		return
	
	var scale = _calculate_best_fullscreen_scale()
	print("DisplayManager: Fullscreen with %dx integer scale" % scale)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _state_exit_fullscreen() -> void:
	pass  # Cleanup if needed

# ============================================================
# PUBLIC API
# ============================================================

## Toggle between windowed and fullscreen
func toggle_fullscreen() -> void:
	if current_state == State.WINDOWED:
		_change_state(State.FULLSCREEN)
	else:
		_change_state(State.WINDOWED)

## Set window scale in windowed mode (2x, 3x, 4x, 6x)
func set_window_scale(scale:int) -> void:
	if current_state != State.WINDOWED:
		push_error("DisplayManager: set_window_scale() only allowed in WINDOWED mode")
		return
	
	if scale not in WINDOW_SCALES:
		push_error("DisplayManager: Scale %d not allowed. Allowed values: %s" % [scale, WINDOW_SCALES])
		return
	
	current_window_scale = scale
	var new_width = BASE_WIDTH * scale
	var new_height = BASE_HEIGHT * scale
	
	if not _is_editor_embedded():
		DisplayServer.window_set_size(Vector2i(new_width, new_height))
		_center_window()
		print("DisplayManager: Window scale set to %dx (%d×%d)" % [scale, new_width, new_height])
	else:
		print("DisplayManager: Scale change ignored (editor embedded mode)")
	
	_save_settings()  # Save settings

## Returns current scale factor
func get_current_scale() -> int:
	if current_state == State.FULLSCREEN:
		return _calculate_best_fullscreen_scale()
	else:
		return current_window_scale

## Is fullscreen active?
func is_fullscreen() -> bool:
	return current_state == State.FULLSCREEN

# ============================================================
# PRIVATE METHODS
# ============================================================

func _initialize_display() -> void:
	# Ensure viewport stretch is configured correctly
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	get_window().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	
	# Set clear color to pure black (removes gray/teal Godot background)
	RenderingServer.set_default_clear_color(Color.BLACK)
	
	print("DisplayManager: Initialized (Base: %d×%d)" % [BASE_WIDTH, BASE_HEIGHT])

func _calculate_best_fullscreen_scale() -> int:
	var screen_size = DisplayServer.screen_get_size()
	var max_scale_x = int(screen_size.x / BASE_WIDTH)
	var max_scale_y = int(screen_size.y / BASE_HEIGHT)
	var scale = min(max_scale_x, max_scale_y)
	
	# At least 1x, maximum in WINDOW_SCALES
	scale = max(1, scale)
	
	# Find largest allowed scale that fits
	for allowed_scale in WINDOW_SCALES:
		if allowed_scale <= scale:
			scale = allowed_scale
	
	return scale

func _center_window() -> void:
	var screen_size = DisplayServer.screen_get_size()
	var window_size = DisplayServer.window_get_size()
	var center_pos = (screen_size - window_size) / 2
	DisplayServer.window_set_position(center_pos)

func _load_settings() -> void:
	var config = ConfigFile.new()
	var err = config.load(_config_path)
	
	if err == OK:
		current_window_scale = config.get_value("display", "window_scale", 2)
		print("DisplayManager: Saved settings loaded (Scale: %dx)" % current_window_scale)
	else:
		print("DisplayManager: No saved settings found - using defaults")

func _save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("display", "window_scale", current_window_scale)
	config.set_value("display", "last_state", State.keys()[current_state])
	config.save(_config_path)
	print("DisplayManager: Settings saved")

func _is_editor_embedded() -> bool:
	# Check if running in Godot editor's embedded game window
	return OS.has_feature("editor") and DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED and DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_EXTEND_TO_TITLE)
