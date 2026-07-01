import os

files = [
    'lib/screens/palette_generator_screen.dart',
    'lib/screens/saved_palettes_screen.dart',
    'lib/screens/palette_detail_screen.dart',
    'lib/screens/image_color_extractor_screen.dart',
    'lib/screens/pattern_creator_screen.dart'
]

for f in files:
    with open(f, 'r') as file:
        content = file.read()
    content = content.replace('if (!context.mounted) return;', 'if (!mounted) return;')
    with open(f, 'w') as file:
        file.write(content)

