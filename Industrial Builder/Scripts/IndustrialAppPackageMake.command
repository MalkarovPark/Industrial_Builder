#
# Create an empty Swift application project package
#

#!/bin/bash

# Work around macOS double-click issue
# Set directory where Terminal opens .command from
CALL_DIR="$(osascript -e 'tell application "Finder" to set p to (POSIX path of (target of front window as alias))')"

# Ask for the project name
if [ -n "$1" ]; then
    PROJECT_NAME="$1"
else
    echo "Enter project name: "
    read PROJECT_NAME
fi

# Check if the name is not empty
if [[ -z "$PROJECT_NAME" ]]; then
    echo "Error: Project name cannot be empty"
    exit 1
fi

# Add _Project suffix
PACKAGE_NAME_WITH_POSTFIX="${PROJECT_NAME}_Project"
PACKAGE_DIR="$CALL_DIR/$PACKAGE_NAME_WITH_POSTFIX"

# Check if the directory already exists
if [ -d "$PACKAGE_DIR" ]; then
    echo "Directory $PACKAGE_DIR already exists. Exiting."
    exit 1
fi

# Create the directory
mkdir "$PACKAGE_DIR"
cd "$PACKAGE_DIR" || exit

# Create Package.swift
PACKAGE_SWIFT_CONTENT='
// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "'"$PROJECT_NAME"'",
    platforms: [
        .iOS("17.0"),
        .macOS("14.0")
    ],
    dependencies: [
        .package(url: "https://github.com/MalkarovPark/IndustrialKit", branch: "main"),
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
