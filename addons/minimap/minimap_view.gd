class_name MinimapView
extends Control
## GDScript minimap rendering shell (2D and 3D share this). Presentation-only:
## it consumes a neutral [MinimapSnapshot] and draws it via [MinimapTransform] /
## [MinimapTheme] / [MinimapMarkerView]. It never reads the ECS world or mutates
## gameplay. The camera-direction wedge rotates with the camera while the map
## stays north-up (#515/#517). See issue #588.

var snapshot: MinimapSnapshot = null
var theme_: MinimapTheme = null
var xform: MinimapTransform = null
var interaction: MinimapInteractionController = null

var _marker_view: MinimapMarkerView = null
var _collapsed_size := Vector2(28.0, 28.0)


func _ready() -> void:
	_marker_view = MinimapMarkerView.new()
	if theme_ == null:
		theme_ = MinimapTheme.new()
	if interaction == null:
		interaction = MinimapInteractionController.new()
	interaction.collapsed_changed.connect(_on_collapsed_changed)
	gui_input.connect(_on_gui_input)
	queue_redraw()


## Size the map. The control is sized to [param size]; the transform's map rect
## is set to the full control rect. [param world_bounds] feeds the transform.
func configure(size: Vector2, world_bounds: Rect2, faction_colors: Array[Color] = []) -> void:
	theme_ = MinimapTheme.new(faction_colors)
	_set_size(size)
	xform = MinimapTransform.new(world_bounds, Rect2(Vector2.ZERO, size))
	queue_redraw()


func _set_size(size: Vector2) -> void:
	custom_minimum_size = size
	if is_inside_tree():
		self.size = size


func set_snapshot(p_snapshot: MinimapSnapshot) -> void:
	snapshot = p_snapshot
	if xform != null and snapshot != null:
		xform.world_bounds = snapshot.world_bounds
	queue_redraw()


func set_collapsed(collapsed: bool) -> void:
	if interaction != null:
		interaction.collapsed = collapsed
	queue_redraw()


func _on_collapsed_changed(_c: bool) -> void:
	queue_redraw()


func _on_gui_input(event: InputEvent) -> void:
	if interaction == null or xform == null:
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			var local := (mb.position if mb.position != Vector2.ZERO else get_local_mouse_position())
			if interaction.is_inside(local, xform):
				interaction.handle_click(local, xform)


func _draw() -> void:
	if theme_ == null or xform == null:
		return
	if interaction != null and interaction.collapsed:
		_draw_collapsed()
		return

	# Map body + frame.
	draw_rect(xform.map_rect, theme_.background_color())
	draw_rect(xform.map_rect, theme_.frame_color(), false, 1.5)

	if snapshot == null:
		return

	# Markers (controlled player drawn last so it sits on top).
	var controlled: MinimapMarker = snapshot.controlled_marker()
	for m: MinimapMarker in snapshot.markers:
		if m == controlled:
			continue
		if m.kind == MinimapMarker.Kind.CONTROLLED_PLAYER:
			continue
		if not m.is_known():
			continue
		_marker_view.draw(self, m, xform, theme_)

	# Camera-direction wedge at the camera center (north-up map).
	var center_map: Vector2 = xform.world_to_map(snapshot.camera_center)
	var wedge := xform.camera_wedge_points(center_map, snapshot.camera_facing, 0.5, 14.0)
	draw_colored_polygon(wedge, Color(1.0, 1.0, 1.0, 0.25))
	draw_circle(center_map, 2.0, Color(1.0, 1.0, 1.0, 0.6))

	if controlled != null and controlled.is_known():
		_marker_view.draw(self, controlled, xform, theme_)


func _draw_collapsed() -> void:
	var r := _collapsed_size * 0.5
	draw_rect(Rect2(Vector2.ZERO, _collapsed_size), theme_.frame_color())
	draw_circle(_collapsed_size * 0.5, r.x * 0.5, theme_.frame_color())
