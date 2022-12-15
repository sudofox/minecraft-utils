#!/bin/bash
# by sudofox, with much love to Ari
# to create .mcworld files from all the folders in the cwd (when executed, you should be sitting inside the minecraftWorlds dir)
# these can be restored by minecraft bedrock on android


# store the directory containing the directories to be zipped
SRC_DIR=$(pwd)

# store the directory where the zip files should be created
DEST_DIR=~/Documents/MCBackup/mcworlds

# create the destination directory if it doesn't exist
if [ ! -d "$DEST_DIR" ]; then
  mkdir -p "$DEST_DIR"
fi

# loop through the directories in the source directory
for d in "$SRC_DIR"/*/ ; do
  # extract the directory name from the full path
  dir_name=$(basename "$d")

  # navigate to the directory
  cd "$d"

  # create a zip file of the current directory with the same name
  zip -r "$DEST_DIR/${dir_name}.mcworld" .

  # navigate back to the original directory
  cd "$SRC_DIR"
done

