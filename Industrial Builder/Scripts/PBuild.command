#
# Build application project package to unix executable file
#

#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$(dirname "$0")"

# Determine the package directory based on the input argument
if [ -n "$1" ]; then
    INPUT="$1"
    # If the input is a directory, use it
    if [ -d "$INPUT" ]; then
        PACKAGE_DIR="$INPUT"
        PACKAGE_NAME=$(basename "$PACKAGE_DIR")
        # Remove "_project" suffix if present
        PACKAGE_NAME_BASE="${PACKAGE_NAME/_Project}"
    # If the input is a file, get its parent directory
    elif [ -f "$INPUT" ]; then
        PACKAGE_DIR=$(dirname "$INPUT")
        PACKAGE_NAME=$(basename "$PACKAGE_DIR")
         # Remove "_project" suffix if present
        PACKAGE_NAME_BASE="${PACKAGE_NAME/_Project}"
    else
        echo "Error: The provided argument '$INPUT' is neither a directory nor a file."
        exit 12
    fi
else
    echo "Enter package name: "
    read PACKAGE_NAME
    PACKAGE_DIR="$SCRIPT_DIR/$PACKAGE_NAME"
    # Remove "_project" suffix if present
    PACKAGE_NAME_BASE="${PACKAGE_NAME/_Project}"
fi

# Check if the package directory exists
if [ ! -d "$PACKAGE_DIR" ]; then
    echo "Error: The directory '$PACKAGE_DIR' does not exist."
    exit 1
fi

# Check if the Package.swift file exists in the specified directory
if [ ! -f "$PACKAGE_DIR/Package.swift" ]; then
    echo "Error: Could not find Package.swift in the directory '$PACKAGE_DIR'."
    exit 1
fi


# Get the parent directory of the package
PARENT_DIR=$(dirname "$PACKAGE_DIR")

# Build and move the executable file
swift build --package-path "$PACKAGE_DIR" --configuration release && \
mv "$PACKAGE_DIR/.build/release/$PACKAGE_NAME_BASE" "$PARENT_DIR"
