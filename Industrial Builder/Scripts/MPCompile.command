#
# Compile all program components in modules to unix executable files
#

#!/bin/bash

echo "Initiating compilation of external modules..."

# Find directories ending with .robot, .tool, .part, or .changer
find . -maxdepth 1 -type d \( -name "*.robot" -o -name "*.tool" -o -name "*.part" -o -name "*.changer" \) -print0 | while IFS= read -r -d $'\0' dir; do

  found_dirs=true

  # Get the directory extension
  dir_ext="${dir##*.}"

  # Get the module name (directory name without extension)
  module_name="${dir%.*}"
  module_name=$(basename "$module_name")

  # Find all .swift files within the found directory
  find "$dir" -name "*.swift" -print0 | while IFS= read -r -d $'\0' file; do
    # Extract the filename with extension
    filename=$(basename "$file")

    # Build the command, using the relative path and filename
    command="./LCompile.command \"$file\" -c"

    # Output the custom message with the filename and module name
    echo "Compiling $filename for the external ${dir_ext} module - ${module_name}"

    # Execute the command, redirecting output and error streams to /dev/null
    eval "$command" >/dev/null 2>&1
  done
done

echo "Compilation of external modules completed"
