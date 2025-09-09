extends Control

var start_time = 0.0
var end_time = 0.0
var timer_end = false
var deliveries = 0

func set_deliveries(x):
	deliveries = x
	$DeliveriesRemaining.text = "Deliveries remaining: " + str(deliveries)
func decrement_deliveries():
	deliveries -= 1
	$DeliveriesRemaining.text = "Deliveries remaining: " + str(deliveries)
	
func start_timer():
	start_time = Time.get_ticks_msec()/1000.0
func end_timer():
	end_time = Time.get_ticks_msec()/1000.0
	
func level_failed():
	$GameStop/Retry.show()
	$GameStop/NextLevel.hide()
	$GameStop/Failed.show()
	$GameStop/Completed.hide()
	$GameStop.show()
func level_passed():
	$GameStop/Retry.show()
	$GameStop/NextLevel.show()
	$GameStop/Failed.hide()
	$GameStop/Completed.show()
	$GameStop.show()
	
func hide_menu():
	$GameStop.hide()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_menu()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# update timer
	var timer_text = "" 
	if end_time == 0.0:
		timer_text = "%4.2f" % (Time.get_ticks_msec()/1000.0 - start_time)
	else:
		timer_text = "%4.2f" % (end_time - start_time)
	$Timer.text = timer_text
	pass


func _on_retry_button_down() -> void:
	# This restarts the current scene.
	get_tree().reload_current_scene()
	pass # Replace with function body.


func _on_next_level_button_down() -> void:
	pass # Replace with function body.
