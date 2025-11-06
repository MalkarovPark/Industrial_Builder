#
# BuildModulePrograms.command
#
# Processes directories containing Code folders:
#   - Converts Swift listings into projects
#   - Builds projects into executables
#   - Lists .robot/.tool/.part/.changer files
# Modes:
#   -programs          Keep only programs after build.
#   -projects          Create only projects (do not build programs).
#   -projects-programs Keep both projects and programs.
#   (no argument)      Only build existing projects.
# Arguments:
#   -clear             Build and delete projects after building.
#   <directories>      List of directories to process (prompted if not provided).
#

#!/bin/bash

# Determine clear flag
CLEAR_FLAG=false
if [[ "$1" == "-clear" ]]; then
    CLEAR_FLAG=true
    shift
fi

# Determine mode argument
mode=""
mode_description=""

if [[ "$1" == "-programs" || "$1" == "-projects" || "$1" == "-projects-programs" ]]; then
    mode="$1"
    shift
fi

case "$mode" in
    -programs)
        mode_description="Mode: Programs — keep only programs after build."
        ;;
    -projects)
        mode_description="Mode: Projects — create only projects."
        ;;
    -projects-programs)
        mode_description="Mode: Projects & Programs — keep projects and programs."
        ;;
    *)
        mode_description="Mode: Default — build only."
        ;;
esac

# Collect input directories
if [ $# -eq 0 ]; then
    echo "Enter modules packages manually:"
    read -r input_line
    eval "dirs=($input_line)"
else
    dirs=("$@")
fi

if [ ${#dirs[@]} -eq 0 ]; then
    echo "No input provided. Exiting."
    exit 1
fi

for dir in "${dirs[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "Directory does not exist: $dir"
        continue
    fi
    
    CODE_DIR="$dir/Code"
    if [ ! -d "$CODE_DIR" ]; then
        echo "No 'Code' directory in: $dir"
        continue
    fi
    
    # echo "Code Folder: $CODE_DIR"
    # echo "Processing ${dir##*.} Module – $(basename "${dir%.*}")"
    echo "Start processing "$(basename "${dir%.*}")" $(basename "${dir##*.}" | awk '{print toupper(substr($0,1,1)) substr($0,2)}') Module"
    
    shopt -s nullglob
    
    # Find top-level .swift files
    SWIFT_FILES=("$CODE_DIR"/*.swift)
    
    if [ ${#SWIFT_FILES[@]} -gt 0 ]; then
        # Swift listings found
        for swift_file in "${SWIFT_FILES[@]}"; do
            LISTING_NAME=$(basename "$swift_file" .swift)
            PROJECT_NAME="${LISTING_NAME}_Project"
            PROJECT_DIR="$CODE_DIR/$PROJECT_NAME"
            
            # echo "Process component – $(basename "${LISTING_NAME}")"
            # echo "Build "$(basename "${dir%.*}")" $(basename "${dir##*.}" | awk '{print toupper(substr($0,1,1)) substr($0,2)}') Module – $(basename "${LISTING_NAME}")"

            if [ "$CLEAR_FLAG" = true ]; then
                # Build project and delete it after compilation
                ./ListingToProject.command "$swift_file" >/dev/null 2>&1
                ./ProjectToProgram.command -clear "$PROJECT_DIR" >/dev/null 2>&1
            else
                case "$mode" in
                    -programs)
                        ./ListingToProject.command -clear "$swift_file" >/dev/null 2>&1
                        ./ProjectToProgram.command -clear "$PROJECT_DIR" >/dev/null 2>&1
                        ;;
                    -projects)
                        ./ListingToProject.command -clear "$swift_file" >/dev/null 2>&1
                        ;;
                    -projects-programs)
                        ./ListingToProject.command -clear "$swift_file" >/dev/null 2>&1
                        ./ProjectToProgram.command "$PROJECT_DIR" >/dev/null 2>&1
                        ;;
                    *)
                        ./ProjectToProgram.command "$PROJECT_DIR" >/dev/null 2>&1
                        ;;
                esac
            fi
            
            # echo "Built "$(basename "${dir%.*}")" $(basename "${dir##*.}" | awk '{print toupper(substr($0,1,1)) substr($0,2)}') Module – $(basename "${LISTING_NAME}")"
            echo "Built "$(basename "${dir%.*}")" $(basename "${dir##*.}" | awk '{print toupper(substr($0,1,1)) substr($0,2)}') Module – $(basename "$swift_file")"
        done
    else
        # No .swift listings, check for existing *_Project folders
        for project_dir in "$CODE_DIR"/*_Project; do
            if [ -d "$project_dir" ]; then
                if [ "$CLEAR_FLAG" = true ]; then
                    ./ProjectToProgram.command -clear "$project_dir" >/dev/null 2>&1
                else
                    ./ProjectToProgram.command "$project_dir" >/dev/null 2>&1
                fi
                
                # echo "Built "$(basename "${dir%.*}")" $(basename "${dir##*.}" | awk '{print toupper(substr($0,1,1)) substr($0,2)}') Module – $(basename "${project_dir%_Project}")"
                echo "Built "$(basename "${dir%.*}")" $(basename "${dir##*.}" | awk '{print toupper(substr($0,1,1)) substr($0,2)}') Module – $(basename "$project_dir")"
            fi
        done
    fi
    
    # List .robot, .tool, .part, .changer files (no build action)
    OTHER_FILES=()
    for ext in robot tool part changer; do
        for f in "$CODE_DIR"/*.$ext; do
            OTHER_FILES+=("$f")
        done
    done
    
    for other_file in "${OTHER_FILES[@]}"; do
        echo "Found file: $(basename "$other_file") (no build action applied, only listed)"
    done
    
    echo
done
