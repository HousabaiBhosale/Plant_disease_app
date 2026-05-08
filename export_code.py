import os

def export_codebase():
    base_dir = r"c:\Users\HP\PlantDiseaseApp"
    output_file = os.path.join(base_dir, "project_code_export.txt")
    
    # Directories to scan and extensions to include
    targets = [
        {"dir": "plant_disease_backend/app", "ext": [".py"]},
        {"dir": "plant_disease_backend", "ext": [".py"], "max_depth": 1}, # Top level scripts like main.py
        {"dir": "plant-disease-dashboard/src", "ext": [".js", ".css"]},
        {"dir": "plant_disease_app/lib", "ext": [".dart"]}
    ]
    
    with open(output_file, "w", encoding="utf-8") as outfile:
        outfile.write("====== PLANT DISEASE APP CODEBASE EXPORT ======\n\n")
        
        for target in targets:
            target_dir = os.path.join(base_dir, target["dir"])
            if not os.path.exists(target_dir):
                continue
                
            for root, dirs, files in os.walk(target_dir):
                # Calculate depth
                depth = root[len(target_dir):].count(os.sep)
                if "max_depth" in target and depth >= target["max_depth"]:
                    dirs.clear() # Prevent descending further
                    
                for file in files:
                    if any(file.endswith(ext) for ext in target["ext"]):
                        file_path = os.path.join(root, file)
                        # Relative path for the header
                        rel_path = os.path.relpath(file_path, base_dir)
                        
                        outfile.write(f"\n\n{'='*80}\n")
                        outfile.write(f"FILE: {rel_path}\n")
                        outfile.write(f"{'='*80}\n\n")
                        
                        try:
                            with open(file_path, "r", encoding="utf-8") as infile:
                                outfile.write(infile.read())
                        except Exception as e:
                            outfile.write(f"// Error reading file: {str(e)}\n")

    print(f"Codebase exported successfully to: {output_file}")

if __name__ == "__main__":
    export_codebase()
