extends Node2D
class_name Player

# The state property we want Netfox to track
var network_position: Vector2 = Vector2.ZERO

@onready var rollback_synchroniser: RollbackSynchronizer = $RollbackSynchronizer

func _ready() -> void:
	# Track the position
	rollback_synchroniser.state_properties = [":network_position"]
	rollback_synchroniser.process_settings()

# Needs to be rollback-aware to be registered to the simulation loop
func _rollback_tick(_delta: float, _tick: int, _is_fresh: bool) -> void:
	pass
