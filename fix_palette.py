import os

filepath = 'lib/screens/palette_generator_screen.dart'
with open(filepath, 'r') as f:
    content = f.read()

content = content.replace('CustomColorSwatch', 'custom_color_swatch')
content = content.replace('color.red', '(color.r * 255.0).round()')
content = content.replace('color.green', '(color.g * 255.0).round()')
content = content.replace('color.blue', '(color.b * 255.0).round()')

with open(filepath, 'w') as f:
    f.write(content)
