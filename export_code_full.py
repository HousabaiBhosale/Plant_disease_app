import os

def export_codebase():
    base_dir = r"c:\Users\HP\PlantDiseaseApp"
    output_file = os.path.join(base_dir, "project_code_export_full.txt")
    
    # Directories to ignore
    ignore_dirs = {
        "node_modules", ".git", "__pycache__", ".venv", "venv", 
        "build", ".dart_tool", "android/app/build", "ios/Pods", 
        "windows/flutter/ephemeral", "linux/flutter/ephemeral", 
        "macos/Flutter/ephemeral", "dist", ".idea", ".vscode"
    }
    
    # Extensions to include
    include_exts = {
        ".py", ".js", ".jsx", ".dart", ".json", ".md", ".html", 
        ".css", ".yaml", ".yml", ".gradle", ".kts", ".txt", ".env",
        ".xml", ".plist", ".properties", ".sh", ".bat"
    }
    
    with open(output_file, "w", encoding="utf-8") as outfile:
        outfile.write("====== FULL PLANT DISEASE APP CODEBASE EXPORT ======\n\n")
        
        for root, dirs, files in os.walk(base_dir):
            # Modify dirs in-place to avoid descending into ignored directories
            dirs[:] = [d for d in dirs if d not in ignore_dirs and not d.startswith('.')]
                
            for file in files:
                ext = os.path.splitext(file)[1].lower()
                
                # Include files with matching extensions, and specific files like Dockerfile
                if ext in include_exts or file.lower() in ["dockerfile", "makefile"]:
                    file_path = os.path.join(root, file)
                    
                    # Skip the output file itself
                    if file_path == output_file:
                        continue
                        
                    # Relative path for the header
                    rel_path = os.path.relpath(file_path, base_dir)
                    
                    # Double check if any part of rel_path contains an ignored directory
                    if any(ignored in rel_path.replace('\\', '/') for ignored in ignore_dirs):
                        continue
                    
                    outfile.write(f"\n\n{'='*80}\n")
                    outfile.write(f"FILE: {rel_path}\n")
                    outfile.write(f"{'='*80}\n\n")
                    
                    try:
                        with open(file_path, "r", encoding="utf-8") as infile:
                            outfile.write(infile.read())
                    except Exception as e:
                        outfile.write(f"// Error reading file: {str(e)}\n")

    print(f"Full codebase exported successfully to: {output_file}")

if __name__ == "__main__":
    export_codebase()
