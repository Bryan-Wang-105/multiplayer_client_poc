extends Node2D

const DEFAULT_PORT: int = 12345
@onready var vbox: VBoxContainer = $VBoxContainer
const printOn = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if printOn:
		print("A")
	multiplayer.peer_connected.connect(self.join_as_client)
	join_server()
	pass # Replace with function body.

func join_server() -> void:
	if printOn:
		print("B")
	var peer = ENetMultiplayerPeer.new()
	peer.create_client('127.0.0.1', DEFAULT_PORT)
	multiplayer.multiplayer_peer = peer
	_print_to_vbox("Joining SERVER")

func join_as_client(id: int) -> void:
	if printOn:
		print("C")
	_print_to_vbox("Connected to server, calling spawn player")
	var client_id: int = multiplayer.get_unique_id()
	var player_name: String = "BRYAN WANG"
	rpc_id(1, "server_spawn_player", client_id, player_name)

@rpc
func create_player_node() -> void:
	if printOn:
		print("D")
	_print_to_vbox("Running spawning Player Code")

@rpc("any_peer")
func server_spawn_player(client_id: int, player_name: String) -> void:
	pass

	
func _print_to_vbox(text: String) -> void:
	if printOn:
		print("E")
	print(text)
	var newLbl: Label = Label.new()
	newLbl.text = text
	vbox.add_child(newLbl)
	newLbl.set_owner(vbox)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
