#!/bin/bash
#
# @author: sudofox
#
# This is a script that uses various CLI utilities and bash to parse a Minecraft
# region file and extract the chunks to a directory. It's not really meant for
# daily use, and was written more as a way for me to practice with bash. :D
#
# if you want debug output, toggle DEBUG to true
# there's also some things you can uncomment to get more debug output
#

echo "+=============================+"
echo "| region-parser.sh by Sudofox |"
echo "+=============================+"

# Some values related to the format
# There are 1,024 chunks in each region file, occupying the first 4096 bytes of the file

# xxd -r -p to get raw binary back from a string like 01020304
# xxd -p -c 8 to get 8 bytes as an unbroken string of hex

DEBUG=false

log_debug() {

	if $DEBUG; then
		tput dim
		echo "$@"
		tput sgr0
	fi

}

usage() {

	echo "Usage: $0 <region file>.mca"
	exit 1

}

# Validation

if [ $# -eq 0 ]; then usage; fi

# File exists?

if [ ! -f $1 ]; then
	echo "[ERROR] Couldn't open chunk file $1"
	usage
fi

if ! command -v xxd >/dev/null; then
	echo '[ERROR] Could not find xxd, please install first.'
	exit 1
fi

filename=$(echo -n $1 | sed 's/\.nbt//g')

if [ ! -d ${filename}_nbt ]; then
	mkdir ${filename}_nbt
else
	echo "[INFO] Deleting all NBT files in ./${filename}_nbt"
	rm -f ${filename}_nbt/*.nbt
fi

chunk_number=-1 # until we get the location of the chunk I guess

for location in $(head -c4096 $1 | xxd -p -c 4); do

	chunk_number=$((chunk_number + 1))
	offset=$((0x${location:0:6}))
	if [[ $offset == 0 ]]; then
		continue # No chunk
	fi

	sectors=$((0x${location:6:2}))

	log_debug "[DEBUG] Chunk number: $chunk_number"
	log_debug "[DEBUG] Raw chunk bytes (hex): $location (offset = $offset (${location:0:6}) || sectors = $sectors)"

	timestamp=$((0x$(tail -c+$((($offset * 4) + 4097)) $1 | head -c4 | xxd -p -c 4)))

	#obtain the length and compression type

	chunkheader=$(tail -c+$(($offset * 4096 + 1)) $1 | head -c5 | xxd -p -c 5)
	log_debug "[DEBUG] chunk $chunk_number header: "$(echo $chunkheader | xxd -r -p | xxd -c 8)
	log_debug "[DEBUG] compression type: $((0x${chunkheader:8:2})) (01=gzip, 02=zlib)"

	chunk_length=$(((16777216 * 0x${chunkheader:0:2}) + (65536 * 0x${chunkheader:2:2}) + (256 * 0x${chunkheader:4:2}) + 0x${chunkheader:6:2}))
	log_debug "[DEBUG] Chunk data (start position, chunk_length): "$(($offset * 4096))", $chunk_length"

	# Decode chunk header.
	if [[ $chunk_length -gt 0 ]]; then #skip zero-length chunks
		#log_debug "[DEBUG] chunk timestamp raw (hex) = $(tail -c+$(($offset+4096)) $1|head -c4|xxd -p -c 4)"
		#log_debug "[DEBUG] chunk timestamp = $timestamp = $(date -d @$timestamp)"
		echo "[INFO] Extracting chunk $chunk_number (modify time: $(date -d @$timestamp)) to ${filename}_nbt/$chunk_number.nbt"

		# We tack on the gzip magic at the beginning, but I believe it's missing something (e.g. crc) at the end of the file. As such, gzip normally errors out, so we ignore that.
		# still seems to be valid after decompression :)

		gzip -dcq <(printf "\x1f\x8b\x08\x00\x00\x00\x00\x00" | cat - <(tail -c+$((($offset * 4096) + 6)) $1 | head -c$(($chunk_length - 1)))) 2>/dev/null >${filename}_nbt/$chunk_number.nbt
	fi
done
