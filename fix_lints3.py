import re
import os

def replace_in_file(filepath, replacements):
    with open(filepath, 'r') as f:
        content = f.read()
    for old, new in replacements:
        content = content.replace(old, new)
    with open(filepath, 'w') as f:
        f.write(content)

replace_in_file('lib/screens/color_picker_screen.dart', [
    ('_selectedColor.red', '(_selectedColor.r * 255.0).round()'),
    ('_selectedColor.green', '(_selectedColor.g * 255.0).round()'),
    ('_selectedColor.blue', '(_selectedColor.b * 255.0).round()'),
])

replace_in_file('lib/screens/palette_generator_screen.dart', [
    ('color.red', '(color.r * 255.0).round()'),
    ('color.green', '(color.g * 255.0).round()'),
    ('color.blue', '(color.b * 255.0).round()'),
])

