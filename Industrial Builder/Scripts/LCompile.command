#
# Convert swift source file to unix executable file
#

#!/bin/bash

# Initialize delete flag
delete_project=false

# Determine input
if [ $# -eq 0 ]; then
    echo "Enter swift file name: "
    read filename

    if [[ ! -f "$filename" ]]; then
        echo "Error: File does not exist: $filename"
        exit 1
    fi

    if [[ "$filename" != *.swift ]]; then
        echo "Error: File is not a .swift file: $filename"
        exit 1
    fi

    echo "Clear source files? [y/n]: "
    read answer
    if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
        delete_project=true
    fi
else
    filename="$1"

    # Check for optional -c flag
    if [ "$2" = "-c" ]; then
        delete_project=true
    elif [ $# -eq 2 ]; then
        echo "Usage: $0 <FileName.swift> [-c]"
        exit 1
    fi

    # Validate the file
    if [[ ! -f "$filename" ]]; then
        echo "Error: File does not exist: $filename"
        exit 1
    fi

    if [[ "$filename" != *.swift ]]; then
        echo "Error: File is not a .swift file: $filename"
        exit 1
    fi
fi

# Extract the filename base (without the extension)
filename_base="${filename%.*}"

# Construct the project directory name
project_dir="${filename_base}_Project"

# Check if the file has the .swift extension
if [[ "$filename" != *".swift" ]]; then
    echo "Error: File must have a .swift extension"
    exit 1
fi

# Execute the scripts
# The '&&' ensures that PBuild.command is only executed if LtPConvert.command succeeds.
./LtPConvert.command "$filename" && ./PBuild.command "$project_dir"

# Check the exit code of the last command executed
if [ $? -eq 0 ]; then
  echo "Conversion finished"
  # Delete directory and original file if -c is provided
  if $delete_project ; then
    echo "Deleting Project: $project_dir"
    rm -rf "$project_dir"
     if [ $? -eq 0 ]; then
        echo "Project directory deleted"
      else
        echo "Failed to delete project directory"
      fi
      echo "Deleting source file: $filename"
      rm "$filename"
      if [ $? -eq 0 ]; then
          echo "Source files deleted"
      else
          echo "Failed to delete source files"
      fi
  fi
else
    echo "An error occurred while conversing source"
fi
