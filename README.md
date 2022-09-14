# sudofox/minecraft-utils

Various tools and scripts that I produce while working on Minecraft-related things.

## remove-parrots
Tool for removing parrots from playerdata, made to solve an annoyance on a particular server

Must be run from root of Minecraft server folder.

Usage: `./remove-parrots.sh MinecraftUsername`


## inventory-search
Tool for scanning all playerdata files for items within the inventory or Ender Chest.

Invoke it when your current working directory is the root of the Minecraft server folder. Can be used with some regex.

Usage: `./inventory-search.sh cobblestone`
`./inventory-search.sh '[a-z]{1,}_shulker_box'`


## region-parser

Tool that parses a Minecraft region file (.mca) and extracts each chunk to an NBT file.

I plan on making this into some sort of region/chunk search tool to find things like lost tools and items.

Usage: `./region-parser.sh regionfile.mca`


## linux-laptop-touchpad-fix

Two scripts that enable/disable the blocking of touchpad input when a key is pressed. Might need to be tweaked for your specific laptop.

## true-world-time

For any given region file, get the lowest timestamp on a chunk. Run this on all of your region files and then sort the output to find the oldest chunk in your world.

The script only does one at a time, so you'll need to run it on each region file.
