#
# Convert swift source file to application project package
#

#!/bin/bash

# Determine the package directory based on the input argument
if [ -n "$1" ]; then
    SWIFT_FILE="$1"
else
    echo "Enter swift file name: "
    read SWIFT_FILE
fi

# Validate the file
if [[ ! -f "$SWIFT_FILE" ]]; then
    echo "Error: File does not exist: $SWIFT_FILE"
    exit 1
fi

if [[ "$SWIFT_FILE" != *.swift ]]; then
    echo "Error: File is not a .swift file: $SWIFT_FILE"
    exit 1
fi


# Get the filename without extension to be used as package name
PACKAGE_NAME=$(basename "$SWIFT_FILE" .swift)
PACKAGE_NAME_WITH_POSTFIX="${PACKAGE_NAME}_Project" # Add _Project postfix

# Get the absolute path to the passed swift file
ABSOLUTE_SWIFT_FILE=$(readlink -f "$SWIFT_FILE")

# Create the directory for the package in the same directory as the swift file
PACKAGE_DIR="$(dirname "$ABSOLUTE_SWIFT_FILE")/$PACKAGE_NAME_WITH_POSTFIX"


# Check if the directory already exists
if [ -d "$PACKAGE_DIR" ]; then
    echo "Directory $PACKAGE_DIR already exists. Exiting."
    exit 1
fi

# Create the directory
mkdir "$PACKAGE_DIR"
cd "$PACKAGE_DIR" || exit

# Define the Package.swift content with full references and targets
PACKAGE_SWIFT_CONTENT='
// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "'"$PACKAGE_NAME"'",
    platforms: [
        .iOS("17.0"),
        .macOS("14.0")
    ],
    dependencies: [
        .package(url: "https://github.com/MalkarovPark/IndustrialKit", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "'"$PACKAGE_NAME"'",
            dependencies: [
                .product(name: "IndustrialKit", package: "IndustrialKit"),
            ],
            path: "Sources"
        ),
    ]
)
'

# Create Package.swift file
echo "$PACKAGE_SWIFT_CONTENT" > Package.swift

# Create the main.swift file
mkdir Sources
mkdir Sources/"$PACKAGE_NAME"

# Copy content from given swift file into main.swift
cp "$ABSOLUTE_SWIFT_FILE" Sources/"$PACKAGE_NAME"/main.swift

echo "Package '$PACKAGE_NAME_WITH_POSTFIX' created with IndustrialKit dependency and full references"
