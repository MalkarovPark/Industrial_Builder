#
# Compile all program components in modules to unix executable files
#

#!/bin/bash

# Ensure script runs from its own directory
cd "$(dirname "$0")" || exit

echo "Initiating compilation of external modules..."

# Handle command-line arguments
mode="$1"

case "$mode" in
    -c)
        echo "Mode: compile with cleanup (-c)"
        ;;
    -p)
        echo "Mode: convert to projects only (-p)"
        ;;
    -b)
        echo "Mode: build existing projects only (-b)"
        ;;
    "" )
        echo "Mode: compile without cleanup (default)"
        ;;
    *)
        echo "Unknown option: $mode"
        echo "Usage: ./MPCompile.command [-c | -p | -b]"
        exit 1
        ;;
esac

# Find module directories
find . -maxdepth 1 -type d \( -name "*.robot" -o -name "*.tool" -o -name "*.part" -o -name "*.changer" \) -print0 | while IFS= read -r -d $'\0' dir; do

    dir_ext="${dir##*.}"
    module_name=$(basename "${dir%.*}")

    # --- Mode: build existing projects only (-b) ---
    if [ "$mode" = "-b" ]; then
        code_dir="$dir/Code"
        [ -d "$code_dir" ] || continue

        # Iterate only top-level directories inside Code
        find "$code_dir" -maxdepth 1 -mindepth 1 -type d -print0 | while IFS= read -r -d $'\0' project_dir; do
            if [ -f "$project_dir/Package.swift" ]; then
                echo "Building project for ${dir_ext} module - $(basename "$project_dir")"
                command="./PBuild.command \"$project_dir\""
                eval "$command" >/dev/null 2>&1
            fi
        done

        continue
    fi

    # --- Other modes: work with Code directory ---
    code_dir="$dir/Code"
    [ -d "$code_dir" ] || continue

    # Find all .swift files only in Code folder (no recursion)
    find "$code_dir" -maxdepth 1 -type f -name "*.swift" -print0 | while IFS= read -r -d $'\0' file; do
        filename=$(basename "$file")

        case "$mode" in
            -c)
                command="./LCompile.command \"$file\" -c"
                ;;
            -p)
                command="./LtPConvert.command \"$file\""
                ;;
            *)
                command="./LCompile.command \"$file\""
                ;;
        esac

        echo "Processing $filename for ${dir_ext} module - ${module_name}"
        eval "$command" >/dev/null 2>&1
    done

done

echo "Compilation of external modules completed"
