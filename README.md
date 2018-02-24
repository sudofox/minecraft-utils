## sudofox/minecraft-utils

Various tools and scripts that I produce while working on Minecraft-related things.

#### remove-parrots.sh
Tool for removing parrots from playerdata, made to solve an annoyance on a particular server

Must be run from root of Minecraft server folder.

Usage: `./remove-parrots.sh MinecraftUsername`


#### item-search.sh
Tool for scanning all playerdata files for items within the inventory or Ender Chest.

Must be run from root of Minecraft server folder. Can be used with some regex.

Usage: `./item-search.sh cobblestone`
`./item-search.sh '[a-z]{1,}_shulker_box'`
