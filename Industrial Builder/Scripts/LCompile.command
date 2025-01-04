#
# Convert swift source file to unix executable file
#

#!/bin/bash

# Initialize delete flag
delete_project=false

# Check if any arguments were given
if [ $# -eq 0 ]; then
  echo "Usage: $0 <FileName.swift> [-c]"
  exit 1
fi


# Store the filename from the command line argument.
filename="$1"

# Check for the -c flag in the second position
if [ "$2" = "-c" ]; then
    delete_project=true
fi

# If the second parameter is not -c, do nothing.
if [ $# -eq 2 ] && [ "$2" != "-c" ]; then
  echo "Usage: $0 <FileName.swift> [-c]"
  exit 1
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
  echo "Scripts executed successfully."
  # Delete directory and original file if -c is provided
  if $delete_project ; then
    echo "Deleting Project: $project_dir"
    rm -rf "$project_dir"
     if [ $? -eq 0 ]; then
        echo "Project directory deleted."
      else
        echo "Failed to delete project directory."
      fi
      echo "Deleting source file: $filename"
      rm "$filename"
      if [ $? -eq 0 ]; then
          echo "Source file deleted."
      else
          echo "Failed to delete source file."
      fi
  fi
else
    echo "An error occurred while executing scripts."
fi