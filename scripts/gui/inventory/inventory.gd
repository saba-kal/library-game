extends Node

# We decided as a team to just hard-code the inventory slots for initial inventory system implementation.
# A single slot can only ever hold one pre-determined type of item. Players cannot move items around or manage
# their inventory in any way.
@onready var room_key_slot: InventorySlot = $Panel/MarginContainer/Control/GridContainer/RoomKeySlot
@onready var boss_1_slot: InventorySlot = $Panel/MarginContainer/Control/GridContainer/BossKeySlot1
@onready var boss_2_slot: InventorySlot = $Panel/MarginContainer/Control/GridContainer/BossKeySlot2
@onready var boss_3_slot: InventorySlot = $Panel/MarginContainer/Control/GridContainer/BossKeySlot3
@onready var book_1_slot: InventorySlot = $Panel/MarginContainer/Control/GridContainer/BookSlot1
@onready var book_2_slot: InventorySlot = $Panel/MarginContainer/Control/GridContainer/BookSlot2
@onready var book_3_slot: InventorySlot = $Panel/MarginContainer/Control/GridContainer/BookSlot3
@onready var book_4_slot: InventorySlot = $Panel/MarginContainer/Control/GridContainer/BookSlot4


func _ready() -> void:
	self.update_inventory()
	SignalBus.room_key_collected.connect(self.update_inventory)
	SignalBus.room_key_used.connect(self.update_inventory)


func update_inventory() -> void:
	self.room_key_slot.set_stack_size(Game.room_key_count)
	self.room_key_slot.can_be_stacked = Game.room_key_count > 0
	self.room_key_slot.is_disabled = Game.room_key_count == 0

	self.boss_1_slot.is_disabled = !Game.player_has_boss_1_key
	self.boss_2_slot.is_disabled = !Game.player_has_boss_2_key
	self.boss_3_slot.is_disabled = !Game.player_has_boss_3_key

	self.book_1_slot.is_disabled = !Game.player_books.has(1)
	self.book_2_slot.is_disabled = !Game.player_books.has(2)
	self.book_3_slot.is_disabled = !Game.player_books.has(3)
	self.book_4_slot.is_disabled = !Game.player_books.has(4)
