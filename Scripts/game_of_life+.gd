extends Node2D

@export var tile_size: int = 16
@export var update_interval: float = 0.15 # Seconds per generation

# Sparse Infinite Grid: key = Vector2i pos, value = state (1 = Normal, 2 = Red/Inverted)
var grid: Dictionary = {}

var is_paused: bool = false
var time_accumulator: float = 0.0

@onready var camera: Camera2D = $Camera2D
@onready var info_label: Label = $UILayer/InfoLabel
@onready var quit_button: Button = $UILayer/QuitButton

# Camera middle-click panning
var is_panning: bool = false
var pan_start_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Connect Quit Button signal
	quit_button.pressed.connect(_on_quit_button_pressed)
	
	# Set UI Label Text
	update_info_label()

func _process(delta: float) -> void:
	# Generation Timer
	if not is_paused:
		time_accumulator += delta
		if time_accumulator >= update_interval:
			time_accumulator = 0.0
			step_generation()

	# Continuous Camera Movement (WASD / Arrows)
	var pan_speed: float = 500.0 * (1.0 / camera.zoom.x)
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	camera.position += input_dir * pan_speed * delta

	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	# Key Controls
	if event is InputEventKey and event.pressed and not event.echo:
		# Space to Pause/Resume
		if event.keycode == KEY_SPACE:
			is_paused = not is_paused
			update_info_label()
		
		# 'C' to Clear Map
		if event.keycode == KEY_C:
			grid.clear()
			print("Grid cleared!")

	# Zooming
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			camera.zoom = clamp(camera.zoom * 1.1, Vector2(0.05, 0.05), Vector2(10.0, 10.0))
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			camera.zoom = clamp(camera.zoom / 1.1, Vector2(0.05, 0.05), Vector2(10.0, 10.0))

		# Middle-Click Drag
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				is_panning = true
				pan_start_pos = event.position
			else:
				is_panning = false

	if event is InputEventMouseMotion and is_panning:
		var delta_pos = (event.position - pan_start_pos) / camera.zoom
		camera.position -= delta_pos
		pan_start_pos = event.position

	# Tile Editing
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = get_global_mouse_position()
		var grid_pos = Vector2i(floor(mouse_pos.x / tile_size), floor(mouse_pos.y / tile_size))

		if event.button_index == MOUSE_BUTTON_LEFT:
			# Left Click: Toggle Normal Cell (1) / Dead (0)
			if grid.get(grid_pos, 0) == 1:
				grid.erase(grid_pos)
			else:
				grid[grid_pos] = 1

		elif event.button_index == MOUSE_BUTTON_RIGHT:
			# Right Click: Toggle Red Inverted Cell (2) / Dead (0)
			if grid.get(grid_pos, 0) == 2:
				grid.erase(grid_pos)
			else:
				grid[grid_pos] = 2

func step_generation() -> void:
	var next_grid: Dictionary = {}
	var candidates: Dictionary = {} # Set of cell coordinates to check

	# 1. Gather all living cells and ALL their adjacent neighbor coordinates
	for pos in grid.keys():
		candidates[pos] = true
		for dx in [-1, 0, 1]:
			for dy in [-1, 0, 1]:
				candidates[pos + Vector2i(dx, dy)] = true

	# 2. Evaluate rules only on relevant candidate cells
	for pos in candidates.keys():
		var current_state = grid.get(pos, 0)
		var neighbors = count_neighbors(pos)
		var normal_n = neighbors[0]
		var red_n = neighbors[1]
		var total_n = normal_n + red_n

		if current_state > 0:
			# ALIVE CELL RULES
			if current_state == 1:
				# Normal Cell: Survives on 2 or 3 neighbors
				if total_n == 2 or total_n == 3:
					next_grid[pos] = 1
			elif current_state == 2:
				# Red Inverted Cell: Survives on <2 or >3 neighbors (inverted survival rule)
				if total_n < 2:
					next_grid[pos] = 2
		else:
			# DEAD CELL BIRTH RULES
			if total_n == 3:
				# Spawn red if majority of neighbors are red
				next_grid[pos] = 2 if red_n > normal_n else 1

	grid = next_grid

func count_neighbors(pos: Vector2i) -> Array[int]:
	var normal_count: int = 0
	var red_count: int = 0
	
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			if dx == 0 and dy == 0:
				continue
			var state = grid.get(pos + Vector2i(dx, dy), 0)
			if state == 1:
				normal_count += 1
			elif state == 2:
				red_count += 1

	return [normal_count, red_count]

func _draw() -> void:
	# Viewport Culling: Get visible rect in world coordinates to avoid drawing millions of offscreen tiles
	var viewport_rect = get_viewport_rect()
	var visible_min = (camera.position - (viewport_rect.size / 2.0) / camera.zoom) / tile_size
	var visible_max = (camera.position + (viewport_rect.size / 2.0) / camera.zoom) / tile_size
	
	var min_x = int(floor(visible_min.x)) - 1
	var max_x = int(ceil(visible_max.x)) + 1
	var min_y = int(floor(visible_min.y)) - 1
	var max_y = int(ceil(visible_max.y)) + 1

	# Draw living cells within view bounds
	for pos in grid.keys():
		if pos.x >= min_x and pos.x <= max_x and pos.y >= min_y and pos.y <= max_y:
			var state = grid[pos]
			var rect = Rect2(pos.x * tile_size, pos.y * tile_size, tile_size - 1, tile_size - 1)
			if state == 1:
				draw_rect(rect, Color.WHITE)
			elif state == 2:
				draw_rect(rect, Color.RED)

func update_info_label() -> void:
	var status = "PAUSED" if is_paused else "RUNNING"
	info_label.text = """[ %s ]
L-Click: Add/Remove Normal Cell (White)
R-Click: Add/Remove Special Cell (Red)
Space: Pause / Play
WASD / Arrow Keys: Pan Camera
Scroll Wheel: Zoom Camera
C Key: Clear Map""" % status

func _on_quit_button_pressed() -> void:
	get_tree().quit()
