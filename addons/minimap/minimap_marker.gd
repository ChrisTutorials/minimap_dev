class_name MinimapMarker
extends RefCounted
## Serializable, presentation-agnostic minimap entry.
##
## Carries no Control / HUD / icon knowledge; the minimap shell decides how each
## [member kind] is drawn. The game-side [MinimapPresenter] projects authoritative
## facts into this shape, and the minimap never mutates them. See issue #588.

## The shell maps each kind to a shape, color, and label.
enum Kind {
	CONTROLLED_PLAYER,  ## pawn the human controls
	PAWN,               ## another known or visible faction or neutral pawn
	HOSTILE,            ## hostile pawn, gated by the same visibility as the main view
	FACTION_HOME,       ## a faction's home landmark
	DEPOT,              ## a faction depot or storage landmark
	BUILDING,           ## a major player or faction building
	TASK_TARGET,        ## the controlled pawn's accepted faction-task cue
	RESOURCE,           ## a discovered resource node
}

## Stable ECS/world entity id; lets the shell keep identity across frames and
## drop despawned entities.
var id: int = -1

## Marker kind.
var kind: int = Kind.PAWN

## World-space position (2D pixels or 3D world units; both map through
## [WorldLayout] cell math).
var position: Vector2 = Vector2.ZERO

## Owning faction id, or -1 when not faction-owned.
var faction_id: int = -1

## Human-readable label for tooltips and accessibility; never color-only identity.
var label: String = ""

## Whether the player may know this entity exists; hidden markers are dropped
## before the shell sees them.
var hidden: bool = false

## Whether the entity has been discovered; drives reduced-detail rendering.
var discovered: bool = false

## Whether the entity is visible to the player; gates HOSTILE markers like the
## main view.
var visible: bool = false

## Resource or building is exhausted but not yet removed from the world.
var depleted: bool = false

## Entity was destroyed or despawned; the presenter strips these on refresh.
var destroyed: bool = false

func _init(
	p_id: int = -1,
	p_kind: int = Kind.PAWN,
	p_position: Vector2 = Vector2.ZERO,
	p_faction_id: int = -1,
	p_label: String = "",
) -> void:
	id = p_id
	kind = p_kind
	position = p_position
	faction_id = p_faction_id
	label = p_label

## True when the player may see this marker at all.
func is_known() -> bool:
	return not hidden and not destroyed
