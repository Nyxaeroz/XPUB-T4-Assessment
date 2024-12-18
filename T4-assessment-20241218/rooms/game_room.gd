@tool
extends PanelContainer
class_name GameRoom

@export var room_name: String = "Room Name":
	set(name):
		room_name = name
		$MarginContainer/Rows/RoomName.text = name
@export_multiline var room_description: String 	= "Room description":
	set(desc):
		room_description = desc
		$MarginContainer/Rows/RoomDescription.text = desc

@export var room_images: Array[Texture] = []

var exits: Dictionary = {}
var npcs : Array = []
var items: Array = []

func add_item(item: Item):
	items.append(item)

func remove_item(item: Item):
	for i in items:
		if i == item:
			items.erase(item)
			return

func connect_exit_unlocked(direction: String, room: GameRoom, room_2_override_name = "null") -> Exit:
	return _connect_exit(direction, room, false, room_2_override_name)

func connect_exit_locked(direction: String, room: GameRoom, room_2_override_name = "null") -> Exit:
	return _connect_exit(direction, room, true, room_2_override_name)

func _connect_exit(direction: String, room: GameRoom, is_locked: bool = false, room_2_override_name = "null") -> Exit:
	var exit = Exit.new()
	exit.room_1 = self
	exit.room_2 = room
	exit.is_locked = is_locked
	exits[direction] = exit
	
	if room_2_override_name != "null":
		room.exits[room_2_override_name] = exit
	else:
		match direction:
			"north":
				room.exits["south"] = exit
			"east":
				room.exits["west"] = exit
			"south":
				room.exits["north"] = exit
			"west":
				room.exits["east"] = exit
			"hallway":
				room.exits["hallway"] = exit
			"inside":
				room.exits["outside"] = exit
			"outisde":
				room.exits["inside"] = exit
			_:
				printerr("Tried to connect invalid direction " + direction)
	return exit

func get_full_description() -> String:
	var full_description = PackedStringArray([get_room_description()])
	
	var npc_description = get_npc_description()
	if npc_description != "":
		full_description.append(npc_description)
		
	var item_description = get_item_description()
	if item_description != "":
		full_description.append(item_description)
	
	#full_description.append(get_exits_description())
	
	var full_description_string = "\n".join(full_description)
	
	return full_description_string
	
func get_room_description() -> String:
	return "Thijs is now in the %s (%s)" % [Types.wrap_location_text(room_name), room_description]

func get_npc_description() -> String:
	if npcs.size() == 0:
		return ""
	var npc_string = ""
	for npc in npcs:
		npc_string += Types.wrap_npc_text(npc.NPC_name) + " "
	return "People" + ": " + npc_string

func add_npc(npc: NPC):
	npcs.append(npc)

func get_item_description() -> String:
	if items.size() == 0:
		return ""
	var item_string = ""
	for item in items:
		item_string += Types.wrap_item_text(item.item_name) + " "
	return "Items" + ": " + item_string

func get_exits_description() -> String:
	var exits_string = ""
	for exit_key in exits.keys():
		exits_string += Types.wrap_location_text(exit_key) + " "
	return "Exits" + ": " + exits_string
