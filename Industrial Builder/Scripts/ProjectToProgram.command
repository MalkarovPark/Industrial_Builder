#
# ProjectToProgram
#
# Builds a Swift project (<project_name>_Project) into a UNIX executable.
# Arguments:
#   <project_dir>   Path to the project directory.
#   -clear          Deletes the project after building.
#

#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$(dirname "$0")"

# Initialize clear flag
CLEAR_PROJECT=false

# Check if first argument is -clear
if [[ "$1" == "-clear" ]]; then
    CLEAR_PROJECT=true
    shift
fi

# Determine the package directory based on the input argument
if [ -n "$1" ]; then
    INPUT="$1"
    if [ -d "$INPUT" ]; then
        PACKAGE_DIR="$INPUT"
        PACKAGE_NAME=$(basename "$PACKAGE_DIR")
        PACKAGE_NAME_BASE="${PACKAGE_NAME/_Project}"
    elif [ -f "$INPUT" ]; then
        PACKAGE_DIR=$(dirname "$INPUT")
        PACKAGE_NAME=$(basename "$PACKAGE_DIR")
        PACKAGE_NAME_BASE="${PACKAGE_NAME/_Project}"
    else
        echo "Error: The provided argument '$INPUT' is neither a directory nor a file."
        exit 12
    fi
else
    echo "Enter package name: "
    read PACKAGE_NAME
    PACKAGE_DIR="$SCRIPT_DIR/$PACKAGE_NAME"
    PACKAGE_NAME_BASE="${PACKAGE_NAME/_Project}"
fi

# --- Verify that the folder is a valid Swift project ---
if [ ! -f "$PACKAGE_DIR/Package.swift" ]; then
    echo "Error: Not a valid Swift project. Package.swift not found in '$PACKAGE_DIR'."
    exit 1
fi

# Get the parent directory of the package
PARENT_DIR=$(dirname "$PACKAGE_DIR")

# --- Build the executable ---
swift build --package-path "$PACKAGE_DIR" --configuration release

# Check if the executable exists
EXECUTABLE_PATH="$PACKAGE_DIR/.build/release/$PACKAGE_NAME_BASE"
if [ ! -f "$EXECUTABLE_PATH" ]; then
    echo "Error: Build failed. Executable not found at '$EXECUTABLE_PATH'."
    exit 2
fi

# Move executable to parent directory
mv "$EXECUTABLE_PATH" "$PARENT_DIR"

# If -clear flag was specified, remove the original project folder
if $CLEAR_PROJECT; then
    echo "Removing project folder '$PACKAGE_DIR' as requested (-clear)..."
    rm -rf "$PACKAGE_DIR"
fi

echo "Build completed. Executable is located at '$PARENT_DIR/$PACKAGE_NAME_BASE'."
