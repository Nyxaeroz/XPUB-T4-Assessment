extends Resource
class_name Item

@export var item_name : String = "Item name"
@export var item_type : Types.ItemTypes = Types.ItemTypes.KEY

var use_value = null

# currently obsolete -- all items are created as resources in the editor and loaded in the script. But item creation through code possible with this function
func initialize(item_name: String, item_type: Types.ItemTypes):
	self.item_name = item_name
	self.item_type = item_type
