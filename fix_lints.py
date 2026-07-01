import os
import re

def replace_in_file(filepath, replacements):
    with open(filepath, 'r') as f:
        content = f.read()
    
    for old, new in replacements:
        content = content.replace(old, new)
        
    with open(filepath, 'w') as f:
        f.write(content)

def regex_replace_in_file(filepath, replacements):
    with open(filepath, 'r') as f:
        content = f.read()
    
    for pattern, new in replacements:
        content = re.sub(pattern, new, content)
        
    with open(filepath, 'w') as f:
        f.write(content)

# 1. CustomColorSwatch -> custom_color_swatch
files_with_swatch = [
    'lib/screens/color_picker_screen.dart',
    'lib/screens/drawing_pad_screen.dart',
    'lib/screens/image_color_extractor_screen.dart',
    'lib/screens/palette_generator_screen.dart',
    'lib/screens/pattern_creator_screen.dart',
]
for f in files_with_swatch:
    replace_in_file(f, [('CustomColorSwatch', 'custom_color_swatch')])

# 2. .red, .green, .blue, .value
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

for f in color_prop_files:
    regex_replace_in_file(f, [
        (r'\.red\b', r'.r * 255.0).round().clamp(0, 255'),
        (r'\.green\b', r'.g * 255.0).round().clamp(0, 255'),
        (r'\.blue\b', r'.b * 255.0).round().clamp(0, 255'),
    ])
    # For .value we have to be careful since it might not be color.value.
    # We will just manually fix .value where appropriate or use regex.
    # In color_utils.dart: color.value -> color.toARGB32()
    # Let's just fix specific files where we know it's color.value.
    replace_in_file(f, [('color.value', 'color.toARGB32()')])

# Additional specific .value fixes:
replace_in_file('lib/screens/palette_detail_screen.dart', [('colors[i].value', 'colors[i].toARGB32()')])
replace_in_file('lib/screens/home_screen.dart', [('c.value', 'c.toARGB32()'), ('r.value', 'r.toARGB32()')])
replace_in_file('lib/screens/image_color_extractor_screen.dart', [('c.value', 'c.toARGB32()')])
replace_in_file('lib/models/color_palette.dart', [('c.value', 'c.toARGB32()')])

# 3. .withOpacity -> .withValues(alpha: ) in palette_card.dart
replace_in_file('lib/widgets/palette_card.dart', [('.withOpacity(', '.withValues(alpha: ')])

# 4. print -> debugPrint in palette_storage_service.dart
replace_in_file('lib/services/palette_storage_service.dart', [
    ('print(', 'debugPrint(')
])
# Need to add import 'package:flutter/foundation.dart';
with open('lib/services/palette_storage_service.dart', 'r') as f:
    c = f.read()
if 'package:flutter/foundation.dart' not in c:
    c = "import 'package:flutter/foundation.dart';\n" + c
with open('lib/services/palette_storage_service.dart', 'w') as f:
    f.write(c)

