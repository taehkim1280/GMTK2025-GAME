extends Node3D

var deliveries = 0
var level_complete = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	deliveries = $TestLevel/Deliveries.get_child_count()
	$UI.set_deliveries(deliveries)
	$UI.start_timer()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_vehicle_crashed() -> void:
	if not level_complete:
		$UI.end_timer()
		$UI.level_failed()
		pass # Replace with function body.


func _on_vehicle_collected() -> void:
	$UI.decrement_deliveries()
	deliveries -= 1


func _on_vehicle_final_destination_reached() -> void:
	if deliveries == 0 and not level_complete:
		level_complete = true
		$UI.level_passed()
		$UI.end_timer()
