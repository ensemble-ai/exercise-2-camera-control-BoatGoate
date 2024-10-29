class_name TargetFocusLerp
extends CameraControllerBase

@export var lead_speed:float = 1.3
@export var catchup_delay_duration:float = 0.2
@export var catch_up:float = 1.01
@export var leash_distance:float = 11

var camera_speed: float
var camera_catch_up_speed: float

var time_since_last_movement: float = 0.0
var is_waiting: bool = false


func _ready() -> void:
	super()
	position = target.position
	

func _process(delta: float) -> void:
	if !current:
		return
	
	if draw_camera_logic:
		draw_logic()
	
	var tpos = target.global_position
	var cpos = global_position
	var back_direction:Vector3 = (tpos - cpos).normalized()
	calc_camera_speed()
	
	#Get direction of the player
	var input_dir = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		).limit_length(1.0)
	var target_direction = (Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var position_ahead = get_position_ahead(target.position, target_direction, leash_distance);
	
	if(target_direction != Vector3.ZERO):
		#Go ahead of target
		var direction = (position_ahead - cpos).normalized()
		global_position += direction * camera_speed * delta
		time_since_last_movement = 0
	else:
		if time_since_last_movement > catchup_delay_duration:
			global_position += back_direction * camera_catch_up_speed * delta
		else: 
			time_since_last_movement += delta

	super(delta)

func calc_camera_speed() -> void:
	if Input.is_action_pressed("ui_accept"):
		camera_speed = target.HYPER_SPEED * lead_speed
		camera_catch_up_speed = target.HYPER_SPEED * catch_up
	else:
		camera_speed = target.BASE_SPEED * lead_speed
		camera_catch_up_speed = target.HYPER_SPEED * lead_speed
		

func get_position_ahead(origin_position: Vector3, direction: Vector3, distance: float) -> Vector3:
	# Ensure direction is a normalized vector (unit length)
	var normalized_direction = direction.normalized()
  
	# Calculate the position 11 units away in the specified direction
	var ahead_position = origin_position + normalized_direction * distance
	return ahead_position

func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	var line_length:float = leash_distance / 2
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	
	#left to right
	immediate_mesh.surface_add_vertex(Vector3(-line_length, 0, 0))
	immediate_mesh.surface_add_vertex(Vector3(line_length, 0, 0))
	
	#top to bottom
	immediate_mesh.surface_add_vertex(Vector3(0, 0, -line_length))
	immediate_mesh.surface_add_vertex(Vector3(0, 0, line_length))
	

	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.WHITE
	
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	#mesh is freed after one update of _process
	await get_tree().process_frame
	mesh_instance.queue_free()
