extends Resource
class_name NPC

@export var NPC_name : String = "Name"

@export_multiline var pre_dialogue : String
@export_multiline var post_dialogue : String

@export var quest_item : Item
var has_received_quest_item := false
var quest_reward = null
