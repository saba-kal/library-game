extends Node

signal ok_pressed

@onready var master_volume_slider: HSlider = %MasterVolumeSlider
@onready var music_volume_slider: HSlider = %MusicVolumeSlider
@onready var sfx_volume_slider: HSlider = %SFXVolumeSlider
@onready var fullscreen_checkbox: CheckBox = %FullscreenCheckbox
@onready var resolution_dropdown: OptionButton = %ResolutionDropdown
@onready var ok_button: Button = %OkButton


var resolutions: Dictionary = {
	"3840x2160": Vector2i(3840,2160),
	"2560x1440": Vector2i(2560,1440),
	"1920x1080": Vector2i(1920,1080),
	"1366x768": Vector2i(1366,768),
	"1280x720": Vector2i(1280,720),
	"1440x900": Vector2i(1440,900),
	"1600x900": Vector2i(1600,900),
	"1024x600": Vector2i(1024,600),
	"800x600": Vector2i(800,600)
}


func _ready() -> void:
	self.ok_button.pressed.connect(self.on_ok_pressed)
	self.setup_volume_slider(self.master_volume_slider, "Master")
	self.setup_volume_slider(self.music_volume_slider, "Music")
	self.setup_volume_slider(self.sfx_volume_slider, "SFX")
	self.setup_fullscreen_toggle()
	self.setup_resolution_dropdown()


func setup_volume_slider(slider: HSlider, bus_name: String) -> void:
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	var current_value: float = AudioServer.get_bus_volume_db(bus_index)
	slider.value = db_to_linear(current_value) * slider.max_value

	var on_slider_changed: Callable = func(value: float):
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(value / slider.max_value))
	slider.value_changed.connect(on_slider_changed)


func setup_fullscreen_toggle() -> void:
	var window_mode: DisplayServer.WindowMode = DisplayServer.window_get_mode()
	self.fullscreen_checkbox.button_pressed = window_mode == DisplayServer.WINDOW_MODE_FULLSCREEN

	var on_toggled: Callable = func(button_pressed: bool):
		if button_pressed:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		set_resolution_dropdown_disabled(button_pressed)
	self.fullscreen_checkbox.toggled.connect(on_toggled)


func setup_resolution_dropdown() -> void:
	self.resolution_dropdown.clear()
	for resolution_key in self.resolutions:
		self.resolution_dropdown.add_item(resolution_key)
	self.update_selected_resolution()

	var on_changed: Callable = func(index: int):
		var key: String = self.resolution_dropdown.get_item_text(index)
		DisplayServer.window_set_size(self.resolutions[key])
	self.resolution_dropdown.item_selected.connect(on_changed)
	if self.fullscreen_checkbox.button_pressed:
		set_resolution_dropdown_disabled(true)


func set_resolution_dropdown_disabled(is_disabled):
	self.resolution_dropdown.disabled = is_disabled
	self.update_selected_resolution()


func update_selected_resolution():
	var i: int = 0
	for resolution_key in self.resolutions:
		var resolution_value: Vector2i = self.resolutions[resolution_key]
		if DisplayServer.screen_get_size() == resolution_value:
			self.resolution_dropdown.selected = i
		i+=1


func on_ok_pressed() -> void:
	self.ok_pressed.emit()
