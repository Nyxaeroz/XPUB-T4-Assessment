extends Node

var inventory: Array = []

func take_item(item: Item):
	inventory.append(item)

func drop_item(item: Item):
	inventory.erase(item)

func get_inventory_list() -> String:
	if inventory.size() == 0:
		return Types.wrap_system_text("Inventory") + ": empty"
		
	var item_string = ""
	for item in inventory:
		item_string += Types.wrap_item_text(item.item_name) + " "
	return  Types.wrap_system_text("Inventory") + ": " + item_string
