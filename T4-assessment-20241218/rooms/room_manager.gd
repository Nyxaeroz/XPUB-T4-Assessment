extends Node

func _ready() -> void:
	$CommonAreaRoom.connect_exit_unlocked("studio", $StudioRoom, "common-area")
	var locked_exit = $CommonAreaRoom.connect_exit_locked("aquarium", $AquariumRoom, "common-area")
	$CommonAreaRoom.connect_exit_unlocked("office", $OfficeRoom, "common-area")
	#$StudioRoom.connect_exit_unlocked("xml", $XML, "studio")
	
	### items ###
	var key = load_item("CommonAreaAquariumKey")
	key.use_value = locked_exit
	$OfficeRoom.add_item(key)
	
	var scissors = load_item("Scissors")
	$XML.add_item(scissors)
	
	### NPCs ###
	var zuzu = load_npc("zuzu")
	$StudioRoom.add_npc(zuzu)
	
	#var rosa = load_npc("rosa")
	#$StudioRoom.add_npc(rosa)
	
	#var joseph = load_npc("joseph")
	#$OfficeRoom.add_npc(joseph)
	#joseph.quest_reward = locked_exit
	
	var manetta = load_npc("manetta")
	$AquariumRoom.add_npc(manetta)
	
	var marloes = load_npc("marloes")
	$AquariumRoom.add_npc(marloes)
	
	var michael = load_npc("michael")
	$AquariumRoom.add_npc(michael)
	
	var jeanne = load_npc("jeanne")
	$AquariumRoom.add_npc(jeanne)
	
func load_item(item_name: String) -> Item:
	return load("res://items/" + item_name + ".tres")
	
func load_npc(npc_name: String) -> NPC:
	return load("res://npcs/" + npc_name + ".tres")
