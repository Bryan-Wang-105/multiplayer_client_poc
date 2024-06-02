extends CharacterBody3D
@onready var id_label: Label3D = $ID_Label

var level = 6

var SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var direction = Vector3.ZERO
@onready var head = $Head
var mouse_sens = .002
var lerp_speed = 10.0

var capMouse = false

func _ready() -> void:
	if is_multiplayer_authority() == false:
		remove_child(head)
	
	if is_multiplayer_authority() == true:
		remove_child(id_label)
	
	print("In player ready")
	name = str(get_multiplayer_authority())
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sens)
		head.rotate_x(-event.relative.y * mouse_sens)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-85),deg_to_rad(85))

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		# Add the gravity.
		if not is_on_floor():
			velocity.y -= gravity * delta

		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Handle sprint
		if Input.is_action_pressed("sprint") and is_on_floor():
			SPEED = 8
		else:
			SPEED = 5
		
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*lerp_speed)
		
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		
		if Input.is_action_just_pressed("escape"):
			get_tree().quit()
		
		rpc("remote_set_position", global_position)

		move_and_slide()

func set_username(id):
	id_label.text = id
	id_label.visible = true

@rpc("unreliable")
func remote_set_position(authority_position):
	global_position = authority_position