@tool
extends ProgrammaticTheme
'''
See instructions at:
https://github.com/Inspiaaa/ThemeGen
'''

func setup():
	set_save_path("res://src/themes/default_theme.tres")

var button_color = Color.TEAL
var button_hover_color = button_color.darkened(0.05)
var button_pressed_color = button_color.darkened(0.1)

func define_theme():
	# ...
	var button_style = stylebox_flat({
		bg_color = button_color,
	})

	var button_hover_style = inherit(button_style, {
		bg_color = button_hover_color
	})

	var button_pressed_style = inherit(button_style, {
		bg_color = button_pressed_color
	})

	define_style("Button", {
		normal = button_style,
		hover = button_hover_style,
		pressed = button_pressed_style,
	})
	
	define_style("Label", {
		font_size = 20
	})
