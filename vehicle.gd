extends CharacterBody3D

@export_range(0, 10) var min_turn_radius := 5.0

signal crashed
signal collected
signal final_destination_reached

var steering : float = 0.0
var current_velocity = 25.0
# cur_direction.x is the LEFT vector, #cur_direction.z is FORWARD vector
var cur_direction = Basis(Vector3(1.0, 0.0, 0.0), Vector3.UP, Vector3(0.0, 0.0, 1.0))

var turn_cw = true
var turning = true 
var start_time = 0.0
var start_angle = 0.0
var start_position = Vector3(0.0,0.0,0.0)
var turning_axis = Vector3(0, 0, 0)
		
func get_point_under_cursor() -> Vector3:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if not camera:
		pass
	#Get a point projected away from the camera, offset by the cursor
	var mouse_pos = get_viewport().get_mouse_position()
	return Plane(Vector3.UP, Vector3.ZERO).intersects_ray(
		camera.project_ray_origin(mouse_pos),
		camera.project_ray_normal(mouse_pos)) 
	
func start_turn(click_location : Vector3):
	var pending_turning_axis = (click_location - position).dot(cur_direction.x)*cur_direction.x + position
	var turn_radius = (pending_turning_axis - position).length()
	if turn_radius < min_turn_radius:
		pending_turning_axis = sign((click_location - position).dot(cur_direction.x))*min_turn_radius*cur_direction.x + position
	
	# new turning axis accepted!
	turning = true
	turning_axis = pending_turning_axis
	start_time = Time.get_ticks_msec()/1000.0
	start_position = position
	start_angle = atan2((start_position - turning_axis).x, (start_position - turning_axis).z)
	# check turning direction
	var A = Vector2(cur_direction.z.x, cur_direction.z.z)
	var B = Vector2((turning_axis - position).x, (turning_axis - position).z)
	turn_cw = A.cross(B) < 0.0
	
	# display indicators
	$Indicators/TurnIndicator.visible = true
	$Indicators/TurnIndicator.global_position = turning_axis
	$Indicators/TurnIndicator/ring.mesh.inner_radius = (turning_axis - position).length() - 0.2
	$Indicators/TurnIndicator/ring.mesh.outer_radius = (turning_axis - position).length() + 0.2
	$Indicators/AxisIndicator/normal.mesh.size.z = 4*(turning_axis - position).length()
	# Set the cube's transform
	var basis = Basis()
	basis.z = cur_direction.x
	basis.x = cur_direction.x.cross(Vector3.UP).normalized()
	if basis.x.length() < 0.001:
		basis.x = cur_direction.x.cross(Vector3.RIGHT).normalized()
	basis.y = basis.z.cross(basis.x).normalized()
	$Indicators/AxisIndicator/normal.transform = Transform3D(basis, position)
	$Indicators/AxisIndicator/originalPos.global_position = position
	$Indicators/AxisIndicator/click.global_position = click_location
	
func player_die():
	print("Player died")
	crashed.emit()
	queue_free()
	
func exit_turn():
	turning = false
	
func _ready() -> void:
	start_turn(Vector3(-10, 0, 0))
	pass
	
func _physics_process(delta):
	########################################
	################ INPUT #################
	########################################
	if Input.is_action_just_pressed("click"):
		#print("CLICKED! " + str(get_point_under_cursor()) + " turning: " + str(turning) + " at: " + str(Time.get_ticks_msec()/1000.0))
		if turning:
			turning = false
		else:
			start_turn(get_point_under_cursor())
	########################################
	################ COLLISION #################
	########################################
	# Iterate through all collisions that occurred this frame
	for index in range(get_slide_collision_count()):
		var collision = get_slide_collision(index)
		# we will disable delivery destination collider after contact
		if collision.get_collider() == null:
			continue

		if collision.get_collider().is_in_group("destination"):
			var destination = collision.get_collider()
			destination.destination_reached()
			collected.emit()
			break
		elif collision.get_collider().is_in_group("obstacle"):
			var obstacle = collision.get_collider()
			player_die()
			break
		elif collision.get_collider().is_in_group("bounce"):
			var bounce = collision.get_collider()
			var normal = collision.get_normal()
			var angle = collision.get_angle()
			break
		elif collision.get_collider().is_in_group("final_destination"):
			print("FINAL DESTINATION REACHED")
			var final_destination = collision.get_collider()
			final_destination.destination_reached()
			final_destination_reached.emit()
			break
				
	########################################
	################ MOVEMENT #################
	########################################
			
	var target_direction = Vector3(0, 0, 0)
	
	if turning:
		var turning_radius = (start_position - turning_axis).length()
		var elapsed_time = Time.get_ticks_msec()/1000.0 - start_time
		var angular_velocity = current_velocity/turning_radius
		var angle = (1.0 if turn_cw else -1.0)*elapsed_time*angular_velocity + start_angle
		var circle_position = Vector3(
			turning_axis.x + turning_radius*sin(angle),
			0.0,
			turning_axis.z + turning_radius*cos(angle)
		)
		target_direction = circle_position - position
		if target_direction.length() > 0.00001:
			cur_direction = cur_direction.looking_at(target_direction, Vector3.UP, true)
		$Pivot.basis = cur_direction
	else:
		target_direction = cur_direction.z*current_velocity*delta
			
	position += target_direction
	move_and_slide()
		
		
	
