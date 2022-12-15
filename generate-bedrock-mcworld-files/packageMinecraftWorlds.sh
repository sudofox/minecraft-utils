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

  # push the zip file to the Android device
  adb push "$DEST_DIR/${dir_name}.mcworld" /sdcard/mcworld_import/

  # wait for the user to confirm before opening the next world
  read -p "Press enter to open the next world in Minecraft"
done

# loop through the .mcworld files in the mcworld_import directory
for f in /sdcard/mcworld_import/*.mcworld; do
  # open the .mcworld file in Minecraft
  adb shell am start -a android.intent.action.VIEW -d "file://$f" -t application/vnd.minecraft-world

  read -p "Press enter to open the next world in Minecraft"
done
