extends Node

# Networking
@onready var id_lbl: Label = $NetworkingInfo/IDlbl
var multiplayer_peer = ENetMultiplayerPeer.new()
var PORT = 9999
var ADDRESS = "localhost"

# Menu 
@onready var port_text: TextEdit = $"Main Menu/PortLbl/portText"
@onready var address_text: TextEdit = $"Main Menu/AddressLbl/addressText"

# Game World 
@export var game_world_path: String
@export var default_map_path: String
@export var player_path: String
var default_map
var player
var game_world: Node3D
var game_world_scene

# Game State
var connected_players = []
var local_player_char
var inGame = false

# DEBUG
var debugOn = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if debugOn:
		print("A: Ready and preloading game world")
	
	multiplayer.connected_to_server.connect(self._on_connected_to_server)
	multiplayer.connection_failed.connect(self._on_connection_failed)
	
	game_world_scene = load(game_world_path)
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Creating multiplayer connection to server
func _on_join_server_pressed() -> void:
	if debugOn:
		print("B: Creating server and client connection")
		
	if len(port_text.text) > 0 and len(address_text.text) > 0:
		PORT = port_text.text
		ADDRESS = address_text.text
		print("REPLACED TEXT")
	
	# Create client-server connection
	multiplayer_peer.create_client(ADDRESS, PORT)
	multiplayer.multiplayer_peer = multiplayer_peer

func _on_connected_to_server() -> void:
	print("Ba: Connected successfully!")
	# Adding client ID
	id_lbl.text = str(multiplayer.get_unique_id())
	
	# Creates client local game state
	create_game()

func _on_connection_failed() -> void:
	print("Bb: Connection Failure! No Host Found")

# Creating game world and map
func create_game() -> void:
	if debugOn:
		print("H: Creating local game world, default map and hiding menu")
	game_world = game_world_scene.instantiate()
	add_child(game_world)

	default_map = load(default_map_path)
	default_map = default_map.instantiate()
	
	game_world.add_child(default_map)
	
	$"Main Menu".visible = false

# Create other player instance locally
func add_player_character(player_id):
	if debugOn:
		print("F: Creating Player of ID: %s" % player_id)
	
	if player_id == multiplayer.get_unique_id() and inGame == false:
		print("G: Adding LOCAL player and game world")
		local_player_char = player_id
		
	connected_players.append(player_id)
	var player_character = load("res://player/player.tscn").instantiate()
	player_character.set_multiplayer_authority(player_id)
	game_world.add_child(player_character)
	player_character.set_username(str(player_id))


# Add new players into gameworld
@rpc("any_peer")
func add_newly_connected_player(id):
	print("E: Adding new player who just joined via RPC")
	add_player_character(id)

# Add old players into gameworld
@rpc("any_peer")
func add_prev_connected_players(connected_players):
	print("C: Adding previously connected players before join")
	print(connected_players)
	for id in connected_players:
		print("D: Adding prev player now")
		add_player_character(id)
