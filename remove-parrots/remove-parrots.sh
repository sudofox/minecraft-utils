#!/bin/bash

# Remove Parrot from Playerdata file
# by Sudofox

# requires nbted - cargo install nbted
# require jq - for proper parsing of username

# Usage: /path/to/remove_parrot.sh MinecraftUsername

# Fetch color-codes

COLOR_BOLD=$(tput bold);
COLOR_RESET=$(tput sgr0);
COLOR_DIM=$(tput dim);
COLOR_RED=$(tput setaf 1);
COLOR_GREEN=$(tput setaf 2);
COLOR_BLUE=$(tput setaf 4);

INFO_HEADER=$(echo -n "${COLOR_RESET}${COLOR_BOLD}"'[INFO] '$COLOR_RESET);
ERROR_HEADER=$(echo -n "${COLOR_RESET}${COLOR_BOLD}${COLOR_RED}"'[ERROR] '"$COLOR_RESET");

usage() {
	echo "${COLOR_BOLD}Usage:" $0 "MinecraftUsername${COLOR_RESET}"
	exit;
}

echo "${COLOR_BLUE}${COLOR_BOLD}Parrot Removal Tool by Sudofox${COLOR_RESET}"

[ -z "$1" ] && usage

if ! command -v nbted > /dev/null; then echo $ERROR_HEADER'Could not find nbted (cargo install nbted)'; exit 1; fi
if ! command -v jq > /dev/null; then echo $ERROR_HEADER'Could not find jq (for json parsing), please install it first)'; exit 1; fi

# Fetch UUID by username

echo -n $INFO_HEADER'Fetching UUID for '"$1"'... '
UUID=$(curl -s https://api.mojang.com/users/profiles/minecraft/$1|jq -r '.id') #|perl -pe 's/(\w{8})(\w{4})(\w{4})(\w{4})(\w{12})/\1-\2-\3-\4-\5/g')
if [[ $(echo -n $UUID |wc -c)  != 32 ]]; then
	echo "${COLOR_RESET}${COLOR_RED}"'Could not get UUID for username '"$1${COLOR_RESET}"
	exit 1
fi

FORMATTED_UUID=$(echo $UUID|perl -pe 's/(\w{8})(\w{4})(\w{4})(\w{4})(\w{12})/\1-\2-\3-\4-\5/g')

echo $FORMATTED_UUID

# check that we are in the root of the minecraft server
if [ ! -f ./server.properties ]; then
	echo $ERROR_HEADER'Could not find server.properties; we are not in the root directory for the Minecraft server.'
	exit 1;
fi

echo $INFO_HEADER'Checking worlds...'
FOUND_PLAYERDATA=false
for world in $(ls|grep world); do
	if [ -f $world/playerdata/$FORMATTED_UUID.dat ]; then
		FOUND_PLAYERDATA=true
		echo ${INFO_HEADER}${world}: Found $FORMATTED_UUID.dat;
		# Just to make sure we actually have parrots

		CHECK_PARROTS=$(cat $world/playerdata/$FORMATTED_UUID.dat|gzip -dc|strings|egrep "ShoulderEntity(Left|Right)")
		if [[ $(echo -n "$CHECK_PARROTS"|wc -w) -eq 0 ]]; then
			echo ${INFO_HEADER}Found no parrots, exiting.
			exit 0;
		else
			echo ${INFO_HEADER}Found $(echo -n "$CHECK_PARROTS"|wc -w) parrot\(s\).
		fi

		# Check if our NBT lines change before and after our bird removal

		backup_date=$(date +%m-%d-%Y_%H.%M.%S.%Z)
		cp -a $world/playerdata/$FORMATTED_UUID.dat{,.$backup_date.backup}
		echo ${INFO_HEADER}${world}: Backed up player data file to $world/playerdata/$FORMATTED_UUID.dat.$backup_date.backup

		NBT_LINES_PRE_AVICIDE=$(nbted -p $world/playerdata/$FORMATTED_UUID.dat|wc -l)
		REMOVE_PARROT=$(nbted -p $world/playerdata/$FORMATTED_UUID.dat|perl -p0e 's/.([\t]{1,})Compound..ShoulderEntity.+?(?=^([\t]{2})End)[\t]{2}End//gms')
		NBT_LINES_POST_AVICIDE=$(echo "$REMOVE_PARROT"|wc -l)

		if [[ $NBT_LINES_POST_AVICIDE -lt $NBT_LINES_PRE_AVICIDE && $(echo $REMOVE_PARROT|egrep "ShoulderEntity(Left|Right)") -eq 0 ]]; then
			echo ${INFO_HEADER}NBT shortened, $(echo "$CHECK_PARROTS"|wc -w) parrots removed.
		else
			echo ${ERROR_HEADER}NBT did not change, no parrots removed.
			exit 1 # This should not happen if the previous parrot check succeeded (unless someone decides to enter ShoulderEntity(Left|Right) on a book or smth)
		fi

		nbted -r <(echo -n "$REMOVE_PARROT") > $world/playerdata/$FORMATTED_UUID.dat # this overwrites the playerdata file
		echo ${INFO_HEADER}Removed parrots from $1.
		echo ${INFO_HEADER}You may remove $world/playerdata/$FORMATTED_UUID.dat.$backup_date.backup when ready.
		exit 0
	fi
done

if [ "$FOUND_PLAYERDATA" = false ]; then
	echo ${INFO_HEADER}Did not find any playerdata files for $1 \($FORMATTED_UUID\).
	exit;
fi
