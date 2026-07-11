class_name MinimapMarker
extends RefCounted
## One neutral, presentation-agnostic entry on the minimap.
##
## This is the serializable, Bevy/Godot-bridge-stable data contract the
## minimap consumes. It carries NO Control / HUD / icon-rendering knowledge —
## the GDScript minimap shell decides how each [member kind] is drawn. The
## authoritative facts (positions, faction, existence) are projected into this
## shape by the game-side [MinimapPresenter]; the minimap never owns or mutates
## them. See issue #588.

## What the marker represents. The shell maps each kind to a shape/color/label.
enum Kind {
	CONTROLLED_PLAYER,  ## the pawn the human currently controls
	PAWN,               ## another known/visible faction or neutral pawn
	HOSTILE,            ## a hostile pawn (gated by the same visibility as the main view)
	FACTION_HOME,       ## a faction's home landmark
	DEPOT,              ## a faction depot / storage landmark
	BUILDING,           ## a major player/faction building
	TASK_TARGET,        ## the controlled pawn's accepted faction-task target/depot cue
	RESOURCE,           ## a discovered resource node
}

## Stable ECS/world entity id. Lets the shell keep marker identity across
## frames and drop markers whose source entity was despawned.
var id: int = -1

## What this marker is.
var kind: int = Kind.PAWN

## World-space position (pixels for 2D, world units for 3D — both map through
## the same [WorldLayout] cell math, so the contract is presentation-agnostic).
var position: Vector2 = Vector2.ZERO

## Owning faction id, or -1 when not faction-owned.
var faction_id: int = -1

## Human-readable label for tooltips / accessibility. Never color-only identity.
var label: String = ""

## Whether the player is allowed to know this entity exists at all. Markers
## with [member hidden] == true are dropped by the presenter before the shell
## ever sees them (no debug-leak in normal playable mode).
var hidden: bool = false

## Whether the entity has been discovered/seen (drives reduced-detail rendering
## for entities the player knows about but is not currently observing).
var discovered: bool = false

## Whether the entity is currently visible to the player (gates HOSTILE markers
## to the same contract as the main view).
var visible: bool = false

## Resource/building is exhausted but not yet removed from the world.
var depleted: bool = false

## Entity was destroyed/despawned; the presenter strips these on refresh.
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


## A marker is "known" when the player is permitted to see it at all.
func is_known() -> bool:
	return not hidden and not destroyed
