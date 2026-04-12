#
# MakeIndustrialApp
#
# Creates an empty Swift application project package with IndustrialKit support (<name>_Project).
# Arguments:
#   <project_dir | file>   Optional path to a directory or a file.
#                          If provided, the project will be created next to it.
#

#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$(dirname "$0")"

# Determine the target directory / project name source
if [ -n "$1" ]; then
    INPUT="$1"

    if [ -d "$INPUT" ]; then
        # User passed a directory
        TARGET_PARENT_DIR="$INPUT"
        echo "Enter project name: "
        read PROJECT_NAME

    elif [ -f "$INPUT" ]; then
        # User passed a file — use its directory
        TARGET_PARENT_DIR=$(dirname "$INPUT")
        echo "Enter project name: "
        read PROJECT_NAME

    else
        # User passed a project name directly (not a path)
        PROJECT_NAME="$INPUT"
        TARGET_PARENT_DIR="$SCRIPT_DIR"
    fi

else
    # No args — ask for name and create in script directory
    echo "Enter project name: "
    read PROJECT_NAME
    TARGET_PARENT_DIR="$SCRIPT_DIR"
fi

# Validate project name
if [[ -z "$PROJECT_NAME" ]]; then
    echo "Error: Project name cannot be empty"
    exit 1
fi

# Add _Project suffix
PACKAGE_NAME_WITH_POSTFIX="${PROJECT_NAME}_Project"
PACKAGE_DIR="$TARGET_PARENT_DIR/$PACKAGE_NAME_WITH_POSTFIX"

# Check for existing directory
if [ -d "$PACKAGE_DIR" ]; then
    echo "Directory $PACKAGE_DIR already exists. Exiting."
    exit 1
fi

# Create project folder
mkdir "$PACKAGE_DIR"
cd "$PACKAGE_DIR" || exit

# Create Package.swift
PACKAGE_SWIFT_CONTENT='
// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "'"$PROJECT_NAME"'",
    platforms: [
        .iOS("26.0"),
        .macOS("26.0"),
        .visionOS("26.0")
    ],
    dependencies: [
        //.package(url: "https://github.com/MalkarovPark/IndustrialKit", "26.0.0"..<"26.1.0"),
        .package(url: "https://github.com/MalkarovPark/IndustrialKit", branch: "development"),
    ],
    targets: [
        .executableTarget(
            name: "'"$PROJECT_NAME"'",
            dependencies: [
                .product(name: "IndustrialKit", package: "IndustrialKit"),
            ],
            path: "Sources"
        ),
    ]
)
'
echo "$PACKAGE_SWIFT_CONTENT" > Package.swift

# Create Sources/main.swift
mkdir -p Sources/"$PROJECT_NAME"
touch Sources/"$PROJECT_NAME"/main.swift

echo "Package '$PACKAGE_NAME_WITH_POSTFIX' created in $PACKAGE_DIR."
