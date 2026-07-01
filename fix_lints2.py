import os
import re

color_prop_files = [
    'lib/utils/color_utils.dart',
    'lib/services/accessibility_service.dart',
    'lib/screens/color_picker_screen.dart',
    'lib/screens/palette_generator_screen.dart',
    'lib/models/color_palette.dart',
    'lib/screens/home_screen.dart',
    'lib/screens/image_color_extractor_screen.dart',
    'lib/screens/palette_detail_screen.dart',
]

def regex_replace_in_file(filepath, replacements):
    with open(filepath, 'r') as f:
        content = f.read()
    
    for pattern, new in replacements:
        content = re.sub(pattern, new, content)
        
    with open(filepath, 'w') as f:
        f.write(content)

for f in color_prop_files:
    if os.path.exists(f):
        regex_replace_in_file(f, [
            (r'\.r \* 255\.0\)\.round\(\)\.clamp\(0, 255', r'.red'),
            (r'\.g \* 255\.0\)\.round\(\)\.clamp\(0, 255', r'.green'),
            (r'\.b \* 255\.0\)\.round\(\)\.clamp\(0, 255', r'.blue'),
        ])

