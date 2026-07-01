import re
import subprocess

def run_analyze():
    result = subprocess.run(['flutter', 'analyze', '--no-fatal-infos'], capture_output=True, text=True)
    return result.stdout + result.stderr

def fix_file(filepath, line_numbers):
    with open(filepath, 'r') as f:
        lines = f.readlines()
        
    # Process lines in reverse order so inserting/modifying doesn't mess up subsequent line numbers
    # Actually it's easier to just do it in one pass if we don't insert lines but just modify the existing line
    for line_num in sorted(line_numbers, reverse=True):
        idx = line_num - 1
        line = lines[idx]
        
        # Don't add if already added
        if 'context.mounted' in line or 'context.mounted' in lines[idx-1]:
            # It already has a context.mounted check. Maybe it's using the old `mounted` check.
            # Let's replace `if (!mounted)` with `if (!context.mounted)` in the previous few lines.
            for i in range(max(0, idx-3), idx+1):
                if 'if (!mounted)' in lines[i]:
                    lines[i] = lines[i].replace('if (!mounted)', 'if (!context.mounted)')
            continue
            
        # Check if there is a `if (!mounted)` recently, replace it
        replaced = False
        for i in range(max(0, idx-3), idx+1):
            if 'if (!mounted)' in lines[i]:
                lines[i] = lines[i].replace('if (!mounted)', 'if (!context.mounted)')
                replaced = True
        
        if not replaced:
            # Find indentation
            indent = len(line) - len(line.lstrip())
            # Insert `if (!context.mounted) return;\n`
            lines.insert(idx, ' ' * indent + 'if (!context.mounted) return;\n')

    with open(filepath, 'w') as f:
        f.writelines(lines)

output = run_analyze()
file_to_lines = {}

for line in output.split('\n'):
    if 'use_build_context_synchronously' in line:
        # Example: info • Don't use 'BuildContext's across async gaps • lib/screens/drawing_pad_screen.dart:945:32 • use_build_context_synchronously
        parts = line.split(' • ')
        if len(parts) >= 3:
            file_part = parts[2].strip()
            # lib/screens/drawing_pad_screen.dart:945:32
            file_subparts = file_part.split(':')
            if len(file_subparts) >= 2:
                filepath = file_subparts[0]
                line_num = int(file_subparts[1])
                if filepath not in file_to_lines:
                    file_to_lines[filepath] = set()
                file_to_lines[filepath].add(line_num)

for filepath, lines in file_to_lines.items():
    fix_file(filepath, lines)

