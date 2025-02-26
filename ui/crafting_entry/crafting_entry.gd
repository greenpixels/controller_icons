extends MarginContainer

@export var item_dict : Dictionary
@export var item : Item
const TOOLTIP_TEXT := \
"{name}" + \
"\n\n" + \
"{description}\n\n"

const RECIPE_TEXT := "{ingredient_name}\t{has}/{needs}\n"

signal craft_item_pressed(item : Item)

func set_disabled(disabled : bool):
	%CraftButton.disabled = disabled

func _on_craft_button_pressed() -> void:
	if not item: return
	craft_item_pressed.emit(item)
	open_tooltip() # We re-open the tooltip to update its information

func open_tooltip():
	if not item or not item.recipe or not item_dict: return
	
	var recipe_string = ""
	
	for ingredient in item.recipe.ingredients:
		var has_enough : bool = item_dict[ingredient.item.key] >= ingredient.amount if item_dict.has(ingredient.item.key) else false
		recipe_string += RECIPE_TEXT.format({
			"ingredient_name": BBCodeHelper.build(tr(ingredient.item.key + "_NAME")).add_icon(ingredient.item.texture).result(),
			"has": BBCodeHelper.build(str(item_dict[ingredient.item.key] if item_dict.has(ingredient.item.key) else 0)).set_color(Color.WHITE.to_html() if has_enough else Color.INDIAN_RED.to_html()).result(),
			"needs": ingredient.amount
		})
	
	
	TooltipOverlay.describe(self,
	TOOLTIP_TEXT.format({
		"name": tr(item.key + "_NAME"),
		"description": tr(item.key + "_DESC"),
		}) + recipe_string
	
	)

func _on_craft_button_focus_entered() -> void:
	open_tooltip()
