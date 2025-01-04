#
# Code files compilation for external modules
#

#!/bin/bash

# Find directories ending with .robot, .tool, .part, or .changer
find . -maxdepth 1 -type d \( -name "*.robot" -o -name "*.tool" -o -name "*.part" -o -name "*.changer" \) -print0 | while IFS= read -r -d $'\0' dir; do

  found_dirs=true

  # Find all .swift files within the found directory
  find "$dir" -name "*.swift" -print0 | while IFS= read -r -d $'\0' file; do
    # Extract the relative path to the file
    relative_path=$(dirname "$file")

    # Extract the filename with extension
    filename=$(basename "$file")

    # Build the command, using the relative path and filename
    command="./LCompile.command \"${relative_path}/${filename}\" -c"

    # Output the command for debugging (optional)
    echo "Executing: $command"

    # Execute the command
    eval "$command"
  done
done

echo "Done"