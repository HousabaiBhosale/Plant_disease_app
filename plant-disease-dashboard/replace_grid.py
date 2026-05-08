import os
import re

directory = r"c:\Users\HP\PlantDiseaseApp\plant-disease-dashboard\src"

def replace_grid(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    
    # xs, sm, md
    content = re.sub(r'<Grid item xs={([0-9]+)} sm={([0-9]+)} md={([0-9]+)}', r'<Grid size={{ xs: \1, sm: \2, md: \3 }}', content)
    
    # xs, md
    content = re.sub(r'<Grid item xs={([0-9]+)} md={([0-9]+)}', r'<Grid size={{ xs: \1, md: \2 }}', content)

    # xs, sm
    content = re.sub(r'<Grid item xs={([0-9]+)} sm={([0-9]+)}', r'<Grid size={{ xs: \1, sm: \2 }}', content)

    # xs only
    content = re.sub(r'<Grid item xs={([0-9]+)}', r'<Grid size={{ xs: \1 }}', content)

    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {file_path}")

for root, _, files in os.walk(directory):
    for file in files:
        if file.endswith('.js') or file.endswith('.jsx'):
            replace_grid(os.path.join(root, file))

print("Done")
