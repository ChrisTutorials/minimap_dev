class_name MinimapPresenter
extends Node
## Game-side owner of the minimap vertical slice. Drives snapshot collection
## from a [MinimapDataSource] on a bounded interval (not every frame), applies
## Thistletide-specific visibility/discovery policy, injects the live camera
## center/facing, and emits the resulting neutral [MinimapSnapshot] for both
## the 2D and 3D shells to consume. Presentation-only: it never mutates ECS
## truth. See issue #588.

signal snapshot_updated(snapshot: MinimapSnapshot)

var source: MinimapDataSource = null
var world_region: Rect2i = Rect2i()

## Seconds between snapshot rebuilds. Bounded updates, not per-frame (#588).
var update_interval: float = 0.5

## When true, hostile markers the player cannot see are dropped (same contract
## as the main view). The source sets [member MinimapMarker.visible]; this
## policy enforces the hidden-information rule.
var enforce_hostile_visibility: bool = true

var _controlled_player_id: int = -1
var _camera_center: Vector2 = Vector2.ZERO
var _camera_facing: Vector2 = Vector2(0.0, -1.0)
var _timer: Timer = null
var _last: MinimapSnapshot = null


func _ready() -> void:
	_timer = Timer.new()
	_timer.name = "MinimapUpdateTimer"
	_timer.wait_time = update_interval
	_timer.timeout.connect(_on_timer)
	add_child(_timer)
	_timer.start()
	if source != null:
		update_now()


func configure(p_source: MinimapDataSource, p_world_region: Rect2i) -> void:
	source = p_source
	world_region = p_world_region
	if is_inside_tree() and _timer != null:
		update_now()


func set_controlled_player(id: int) -> void:
	if id == _controlled_player_id:
		return
	_controlled_player_id = id
	update_now()


func set_camera(center: Vector2, facing: Vector2) -> void:
	_camera_center = center
	_camera_facing = facing if facing != Vector2.ZERO else _camera_facing
	if _last != null:
		_last.camera_center = _camera_center
		_last.camera_facing = _camera_facing
		snapshot_updated.emit(_last)


func _on_timer() -> void:
	update_now()


## Rebuild the snapshot now and emit it.
func update_now() -> void:
	if source == null:
		return
	var snap: MinimapSnapshot = source.collect(_controlled_player_id)
	snap.camera_center = _camera_center
	snap.camera_facing = _camera_facing
	_apply_visibility_policy(snap)
	snap.revision += 1
	_last = snap
	snapshot_updated.emit(snap)


## Drops markers the player must not see. Hook for stricter discovery rules;
## the MVP enforces the hostile-visibility contract and strips destroyed/hidden
## markers (which the source should already avoid emitting).
func _apply_visibility_policy(snap: MinimapSnapshot) -> void:
	var kept: Array[MinimapMarker] = []
	for m: MinimapMarker in snap.markers:
		if m.destroyed or m.hidden:
			continue
		if enforce_hostile_visibility and m.kind == MinimapMarker.Kind.HOSTILE and not m.visible:
			continue
		kept.append(m)
	snap.markers = kept
