#!/bin/bash
#
# @author sudofox
#
# Inventory Searcher - Searches for items in a player's inventory or ender chest.
#

COLOR_BOLD=$(tput bold)
COLOR_RESET=$(tput sgr0)
COLOR_DIM=$(tput dim)
COLOR_RED=$(tput setaf 1)
COLOR_GREEN=$(tput setaf 2)
COLOR_BLUE=$(tput setaf 4)

INFO_HEADER=$(echo -n "${COLOR_RESET}${COLOR_BOLD}"'[INFO] '$COLOR_RESET)
ERROR_HEADER=$(echo -n "${COLOR_RESET}${COLOR_BOLD}${COLOR_RED}"'[ERROR] '"$COLOR_RESET")

usage() {
	echo "${COLOR_BOLD}Usage:${COLOR_GREEN}${COLOR_DIM}" $0 "minecraft_item_id${COLOR_RESET}"
	echo "${COLOR_BOLD}Example: ${COLOR_GREEN}${COLOR_DIM}"$0" red_shulker_box${COLOR_RESET}"
	echo "${COLOR_BOLD}Takes regex: ${COLOR_GREEN}${COLOR_DIM}"$0" '[a-z]{1,}_shulker_box'${COLOR_RESET}"
	exit
}

echo "${COLOR_BLUE}${COLOR_BOLD}Inventory/Ender Chest search tool by Sudofox${COLOR_RESET}"

[ -z "$1" ] && usage

if ! command -v nbted >/dev/null; then
	echo $ERROR_HEADER'Could not find nbted (cargo install nbted)'
	exit 1
fi
if ! command -v jq >/dev/null; then
	echo $ERROR_HEADER'Could not find jq (for json parsing), please install it first'
	exit 1
fi

# check that we are in the root of the minecraft server
if [ ! -f ./server.properties ]; then
	echo $ERROR_HEADER'Could not find server.properties; we are not in the root directory for the Minecraft server.'
	exit 1
fi

# When we can't pull the username from lastKnownName...
# usage: username_for_uuid <USERNAME>
username_for_uuid() {
	UUID=$(echo -n $1 | tr -d '-')
	echo -n $(curl -s https://api.mojang.com/user/profiles/$UUID/names | jq -r '.[0].name')

}

for i in $(ls world*/playerdata/*.dat); do
	UUID=$(echo -n $i | grep -Po "playerdata/\K.+?(?=\.)")
	NAME=$(nbted -p $i | grep -Po "lastKnownName\"\ \"\K.+?(?=\")")
	if ! [[ $NAME =~ [a-zA-Z0-9_] ]]; then
		NAME=$(username_for_uuid $UUID)
	fi

	CHECK=$(nbted -p $i | grep -Po "String.*\Kminecraft:$1" | awk '{print $0}')

	if ! [[ $(echo "$CHECK" | wc -w) -eq 0 ]]; then
		NAME=$(nbted -p $i | grep -Po "lastKnownName\"\ \"\K.+?(?=\")")
		if ! [[ $NAME =~ [a-zA-Z0-9_] ]]; then
			NAME=$(username_for_uuid $UUID)
		fi
		echo "$CHECK" | awk -v name="$NAME" '{print name " - " $0}'
	fi

done
