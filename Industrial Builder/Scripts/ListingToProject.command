#
# ListingToProject
#
# Converts a Swift listing (.swift) into a project (<listing_name>_Project).
# Arguments:
#   <swift_file>    Path to the Swift file.
#   -clear          Deletes the original Swift file after conversion.
#

#!/bin/bash

# Check for -clear argument
CLEAR_LISTING=false
if [[ "$1" == "-clear" ]]; then
    CLEAR_LISTING=true
    shift
fi

# Determine the Swift file from the argument
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
    echo "Directory $PACKAGE_DIR already exists. Replacing..."
    rm -rf "$PACKAGE_DIR"
fi

# Create the directory
mkdir "$PACKAGE_DIR"
cd "$PACKAGE_DIR" || exit

# Define the Package.swift content with full references and targets
PACKAGE_SWIFT_CONTENT='
// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "'"$PACKAGE_NAME"'",
    platforms: [
        .iOS("26.0"),
        .macOS("26.0"),
        .visionOS("26.0")
    ],
    dependencies: [
        .package(url: "https://github.com/MalkarovPark/IndustrialKit", "5.0.0"..<"6.0.0"),
    ],
    targets: [
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

# Create Sources folder and main.swift
mkdir -p Sources/"$PACKAGE_NAME"

# Copy content from given swift file into main.swift
cp "$ABSOLUTE_SWIFT_FILE" Sources/"$PACKAGE_NAME"/main.swift

# Remove original Swift file if -clear was specified
if $CLEAR_LISTING; then
    rm -f "$ABSOLUTE_SWIFT_FILE"
    echo "Original Swift file '$SWIFT_FILE' has been deleted due to -clear flag."
else
    echo "Original Swift file '$SWIFT_FILE' preserved (no -clear flag)."
fi

echo "Package '$PACKAGE_NAME_WITH_POSTFIX' created with IndustrialKit dependency and full references."
